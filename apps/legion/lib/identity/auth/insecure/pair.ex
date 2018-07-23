defmodule Legion.Identity.Auth.Insecure.Pair do
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Auth.Algorithm.Digestion
  alias Legion.Identity.Auth.Insecure.{Pair, AuthInfo}

  @env Application.get_env(:legion, Legion.Identity.Auth.Insecure)
  @username_length Keyword.fetch!(@env, :username_length)
  @password_length Keyword.fetch!(@env, :password_length)
  @password_digestion Keyword.fetch!(@env, :password_digestion)

  @type digestion_algorithm :: :argon2 | :bcrypt | :pbkdf2

  schema "insecure_authentication_pairs" do
    belongs_to :user, User
    field :username, :string
    field :password, :string, virtual: true
    field :password_digest, :string
    field :digestion_algorithm, Digestion, default: @password_digestion
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :username, :password])
    |> validate_required([:user_id, :username, :password])
    |> validate_length(:username, min: Enum.min(@username_length), max: Enum.max(@username_length))
    |> validate_length(:password, is: @password_length)
    |> foreign_key_constraint(:user_id)
    |> hash_pw()
  end

  defp hash_pw(changeset) do
    if password = get_change(changeset, :password) do
      digest = hashpwsalt(password)

      changeset
      |> put_change(:password_digest, digest)
    else
      changeset
    end
  end

  def hashpwsalt(password) do
    case @password_digestion do
      :argon2 ->
        Comeonin.Argon2.hashpwsalt(password)
      :bcrypt ->
        Comeonin.Bcrypt.hashpwsalt(password)
      :pbkdf2 ->
        Comeonin.Pbkdf2.hashpwsalt(password)
    end
  end

  @doc """
  Retrieves a struct containing the required information to perform instantiation
  of concrete authentication process on a user.
  """
  @spec retrieve_auth_info(User.username()) ::
    {:ok, AuthInfo.t()} |
    {:error, :no_user_verify}
  def retrieve_auth_info(username) do
    query =
      from p1 in Pair,
      left_join: p2 in Pair,
        on: p1.id < p2.id and p1.user_id == p2.user_id,
      join: u in User,
        on: p1.user_id == u.id,
      where: is_nil(p2.id) and
             p1.username == ^username,
      select: %AuthInfo{user_id: u.id,
                        password_digest: p1.password_digest,
                        digestion_algorithm: p1.digestion_algorithm,
                        authentication_scheme: u.authentication_scheme}

    case Repo.one(query) do
      nil ->
        dummy_checkpw(@password_digestion)

        {:error, :no_user_verify}
      auth_info ->
        {:ok, auth_info}
    end
  end

  @doc """
  Checks password with given digestion algorithm.
  """
  @spec checkpw(Keccak.hash(), binary(), Pair.digestion_algorithm()) ::
    :ok |
    {:error, :wrong_password}
  def checkpw(password, hash, alg) do
    result =
      case alg do
        :argon2 ->
          Comeonin.Argon2.checkpw(password, hash)
        :bcrypt ->
          Comeonin.Bcrypt.checkpw(password, hash)
        :pbkdf2 ->
          Comeonin.Pbkdf2.checkpw(password, hash)
      end

    if result do
      :ok
    else
      {:error, :wrong_password}
    end
  end

  defp dummy_checkpw(alg) do
    case alg do
      :argon2 ->
        Comeonin.Argon2.dummy_checkpw()
      :bcrypt ->
        Comeonin.Bcrypt.dummy_checkpw()
      :pbkdf2 ->
        Comeonin.Pbkdf2.dummy_checkpw()
    end
  end
end
