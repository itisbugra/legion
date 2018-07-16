defmodule Legion.Identity.Auth.Insecure.Pair do
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Auth.Algorithm.Digestion

  @env Application.get_env(:legion, Legion.Identity.Auth.Insecure)
  @username_length Keyword.fetch!(@env, :username_length)
  @password_length Keyword.fetch!(@env, :password_length)
  @password_digestion Keyword.fetch!(@env, :password_digestion)

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
end
