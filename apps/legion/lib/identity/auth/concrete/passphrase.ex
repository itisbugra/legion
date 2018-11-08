defmodule Legion.Identity.Auth.Concrete.Passphrase do
  @moduledoc """
  Passphrase (a.k.a. access token) is an artifact of a successful concrete authentication.
  """
  use Legion.Stereotype, :model

  import NaiveDateTime, only: [utc_now: 0, diff: 2]

  alias Legion.Identity.Auth.Concrete.{Passphrase, ActivePassphrase, Passkey, Activity}
  alias Legion.Identity.Auth.Concrete.Passphrase.Invalidation
  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Networking.INET

  @env Application.get_env(:legion, Legion.Identity.Auth.Concrete)
  @maximum_allowed_passphrases Keyword.fetch!(@env, :maximum_allowed_passphrases)

  @typedoc """
  The type of the identifier to uniquely reference a passphrase.
  """
  @type id() :: integer()

  schema "passphrases" do
    belongs_to(:user, User)
    field(:passkey_digest, :binary)
    field(:ip_addr, Legion.Types.INET)
    field(:inserted_at, :naive_datetime, read_after_writes: true)

    has_one(:invalidation, Invalidation, foreign_key: :target_passphrase_id)
    has_many(:activities, Activity)

    field(:passkey, :binary, virtual: true)
  end

  @spec changeset(Passphrase, map) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :passkey_digest, :ip_addr, :passkey])
    |> validate_required([:user_id, :passkey, :ip_addr])
    |> hash_if_required()
  end

  @doc """
  Generates a new passphrase changeset and returns it with the passkey itself in a tuple.
  """
  @spec create_changeset(User.user_or_id(), INET.t()) :: {Passkey.t(), Ecto.Changeset.t()}
  def create_changeset(user_id, ip_addr) when is_integer(user_id) do
    passkey = Passkey.generate()

    changeset =
      Passphrase.changeset(
        %Passphrase{},
        %{user_id: user_id, passkey: passkey, ip_addr: %Postgrex.INET{address: ip_addr}}
      )

    {passkey, changeset}
  end

  def create_changeset(user, ip_addr) when is_map(user),
    do: create_changeset(user.id, ip_addr)

  @doc """
  Creates a changeset and inserts it into the repository.
  """
  @spec create(User.user_or_id(), INET.t()) :: Passkey.t()
  def create(user_or_id, ip_addr) do
    {passkey, changeset} = create_changeset(user_or_id, ip_addr)

    Repo.insert!(changeset)

    passkey
  end

  @doc """
  Checks passphrase quota of the user, returns error if it is
  exceeded.
  """
  def check_passphrase_quota(user_id) do
    count = ActivePassphrase.count_for_user(user_id)

    if count < @maximum_allowed_passphrases do
      :ok
    else
      {:error, :maximum_passphrases_exceeded}
    end
  end

  @doc """
  Searches for a matching passphrase with given user identifier and a
  passkey hash.

  ## Return types

  This function returns a passphrase identifier if there was no faulty conditions.
  However, it might also return errors in following scenarios.

  - `:not_found`: No matching passphrase found.
  - `:invalid`: The passphrase exists, but it is revoked manually.
  - `:timed_out`: The passphrase exists, however it is not valid anymore.

  The interface of the business logic might choose to not show the reason for the
  failed action due to security concerns. Hence, the developer of this API might
  need to take care of the error values implicitly.

  ## Discussion

  We are searching for the passphrases, but not using the `#{ActivePassphrase}`
  view schema. The reason on doing this is, we need to offload the query
  conditionals to the web application instead of the server.

  The passkey itself is a unique index, so it is not overwhelming to query one with this
  attribute on passphrases. The only thing we need to do additionally is looking for
  an invalidation entry, since we are using unique index here, again, we can leverage
  the power of the physical `btree` indexing the invalidations.
  """
  @spec find_passphrase_matching(User.id(), Passkey.t()) ::
          {:ok, Passphrase.id()}
          | {:error, :not_found}
          | {:error, :invalid}
          | {:error, :timed_out}
  def find_passphrase_matching(user_id, passkey) do
    hash = Passkey.hash(passkey)

    query =
      from(p in Passphrase,
        preload: :invalidation,
        where: p.user_id == ^user_id and p.passkey_digest == ^hash,
        select: p
      )

    with passphrase when not is_nil(passphrase) <- Repo.one(query),
         :ok <- validate(passphrase) do
      {:ok, passphrase.id}
    else
      {:error, _error} = any ->
        any

      _ ->
        {:error, :not_found}
    end
  end

  @doc """
  Returns a boolean value indicating if passphrase exists.
  """
  @spec exists?(id()) :: boolean()
  def exists?(passphrase_id) do
    not is_nil(Repo.get(Passphrase, passphrase_id))
  end

  @doc """
  Validates a passphrase with given identifier.
  """
  @spec validate_id(id()) ::
          :ok
          | {:error, :not_found}
          | {:error, :invalid}
          | {:error, :timed_out}
  def validate_id(passphrase_id) do
    if exists?(passphrase_id) do
      query =
        from(p in Passphrase,
          preload: :invalidation,
          where: p.id == ^passphrase_id
        )

      query
      |> Repo.one!()
      |> validate()
    else
      {:error, :not_found}
    end
  end

  @doc """
  Validates given passphrase and returns `:ok`, or an error tuple with a reason.

  A passphrase is valid if and only if it is not invalidated manually and it has not timed out.
  This function checks its invalidation is `nil` and its insertion time is in a viable lifetime
  interval. It returns `{:error, :invalid}` if passphrase is invalidated manually, or
  `{:error, :timed_out}` if passphrase is timed out.

  ## Caveats
  To use this function properly, one should preload `:invalidation` association of the
  passphrase before supplying it as a parameter to this function. Otherwise, nil-check is
  performed against the `:invalidation` field of the struct, it would see the association as
  non-nil since `Ecto.Association.NotLoaded` struct will be there.
  """
  @spec validate(Passphrase) ::
          :ok
          | {:error, :invalid}
          | {:error, :timed_out}
  def validate(passphrase) do
    cond do
      invalidated?(passphrase) ->
        {:error, :invalid}

      timed_out?(passphrase) ->
        {:error, :timed_out}

      true ->
        :ok
    end
  end

  defp invalidated?(passphrase) do
    not is_nil(passphrase.invalidation)
  end

  defp timed_out?(passphrase) do
    env = Application.get_env(:legion, Legion.Identity.Auth.Concrete)
    lifetime = Keyword.fetch!(env, :passphrase_lifetime)
    passed = diff(utc_now(), passphrase.inserted_at)

    passed > lifetime
  end

  defp hash_if_required(changeset) do
    if passkey = get_change(changeset, :passkey) do
      changeset
      |> put_change(:passkey_digest, Passkey.hash(passkey))
    else
      changeset
    end
  end
end
