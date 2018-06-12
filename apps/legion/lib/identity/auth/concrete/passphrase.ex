defmodule Legion.Identity.Auth.Concrete.Passphrase do
  @moduledoc """
  Passphrase (a.k.a. access token) is an artifact of a successful concrete authentication.
  """
  use Legion.Stereotype, :model

  import NaiveDateTime, only: [utc_now: 0, diff: 2]

  alias Legion.Identity.Auth.Concrete.Passphrase
  alias Legion.Identity.Auth.Concrete.Passphrase.Invalidation
  alias Legion.Identity.Auth.Concrete.Passkey
  alias Legion.Identity.Auth.Concrete.Activity
  alias Legion.Identity.Information.Registration, as: User

  schema "passphrases" do
    belongs_to :user, User
    field :passkey_digest, :binary
    field :ip_addr, Legion.Types.INET
    field :inserted_at, :naive_datetime, read_after_writes: true

    has_one :invalidation, Invalidation, foreign_key: :target_passphrase_id
    has_many :activities, Activity

    field :passkey, :binary, virtual: true
  end

  @spec changeset(Passphrase, map) :: Ecto.Changeset.t
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :passkey_digest, :ip_addr, :passkey])
    |> validate_required([:user_id, :passkey, :ip_addr])
    |> hash_if_required()
  end

  @doc """
  Generates a new passphrase changeset and returns it with the passkey itself in a tuple.
  """
  @spec create_changeset(User.user_or_id(), :inet.ip_address) ::
    { Passkey.t, Ecto.Changeset.t }
  def create_changeset(user_id, ip_addr) when is_integer(user_id) do
    passkey = Passkey.generate()

    changeset =
      Passphrase.changeset(%Passphrase{},
                           %{user_id: user_id,
                             passkey: passkey,
                             ip_addr: %Postgrex.INET{address: ip_addr}})

    {passkey, changeset}
  end
  def create_changeset(user, ip_addr) when is_map(user),
    do: create_changeset(user.id, ip_addr)

  @doc """
  Validates given passphrase and returns `:ok`, or an error tuple with a reason.

  A passphrase is valid if and only if it is not invalidated manually and it has not timed out.
  This function checks its invalidation is `nil` and its insertion time is in a viable lifetime
  interval. It returns `{:error, :invalid}` if passphrase is invalidated manually, or
  `{:error, :timed_out}` if passphrase is timed out.

  ### Caveats
  In order to use this function properly, one should preload `:invalidation` association of the
  passphrase before supplying it as a parameter to this function. Otherwise, nil-check is
  performed against the `:invalidation` field of the struct, it would see the association as
  non-nil since `Ecto.Association.NotLoaded` struct will be there.
  """
  @spec validate(Passphrase) ::
    :ok |
    {:error, :invalid} |
    {:error, :timed_out}
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
