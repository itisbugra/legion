defmodule Legion.Identity.Auth.Concrete.TFAHandle do
  @moduledoc """
  Two-factor authentication handles for concrete authentication.
  """
  use Legion.Stereotype, :model

  import Legion.Identity.Auth.TFA.OneTimeCode

  alias __MODULE__, as: TFAHandle
  alias Legion.Identity.Information.Registration
  alias Legion.Identity.Auth.Concrete.Passphrase

  @tfa_env Application.get_env(:legion, Legion.Identity.Auth.Concrete.TFA)
  @lifetime Keyword.fetch!(@tfa_env, :lifetime)

  @otc_env Application.get_env(:legion, Legion.Identity.Auth.OTC)
  @prefix Keyword.fetch!(@otc_env, :prefix)
  @postfix Keyword.fetch!(@otc_env, :postfix)
  @length Keyword.fetch!(@otc_env, :length)
  @regex Regex.compile!("#{@prefix}[0-9]{#{@length}}#{@postfix}")

  schema "concrete_tfa_handles" do
    belongs_to :user, Registration
    field :otc_digest, :string
    belongs_to :passphrase, Passphrase
    field :inserted_at, :naive_datetime, read_after_writes: true

    field :otc, :string, virtual: true
  end

  @doc """
  Creates a changeset with given params.
  """
  @spec changeset(TFAHandle, map) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :otc, :passphrase_id])
    |> validate_required([:user_id, :otc])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:passphrase_id)
    |> hash_if_required()
  end

  @doc """
  Creates a handle with generated OTC in database and returns it.
  """
  @spec create_handle(integer() | Registration) :: 
    {:ok, TFAHandle} |
    {:error, :not_found}
  def create_handle(user = %Registration{}), do: create_handle(user.id)
  def create_handle(user_id) when is_integer(user_id) do
    changes = changeset(%TFAHandle{}, %{user_id: user_id, otc: generate()})

    case Repo.insert(changes) do
      {:ok, handle} ->
        {:ok, handle}
      {:error, _changes} ->
        {:error, :not_found}
    end
  end

  @doc """
  Challenges a handle of a user with given one time code, returns the subject handle if challenge
  was successful.
  """
  @spec challenge_handle(integer() | Registration, OneTimeCode.t()) ::
    {:ok, TFAHandle} |
    {:error, :not_found} |
    {:error, :bad_code}
  def challenge_handle(user = %Registration{}, otc), do: challenge_handle(user.id, otc)
  def challenge_handle(user_id, otc) when is_integer(user_id) do
    if otc =~ @regex do
      query = from th1 in TFAHandle,
              left_join: th2 in TFAHandle,
                on: th1.user_id == th2.user_id and th1.id < th2.id,
              where: is_nil(th2.id) and
                     th1.user_id == ^user_id and
                     is_nil(th1.passphrase_id) and
                     th1.inserted_at > from_now(^((-1) * @lifetime), "second"),
              select: th1

      case Repo.one(query) do
        nil ->
          dummy_checkpw() # a dummy wait to prevent from probing

          {:error, :not_found}
        handle ->
          if checkpw(otc, handle.otc_digest) do
            {:ok, handle}
          else
            {:error, :bad_code}
          end
      end
    else 
      {:error, :bad_code}
    end
  end

  defp hash_if_required(changeset) do
    if otc = get_change(changeset, :otc) do
      changeset
      |> put_change(:otc_digest, hashpwsalt(otc))
    else
      changeset
    end
  end
end
