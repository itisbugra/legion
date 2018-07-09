defmodule Legion.Identity.Auth.Insecure.Pair do
  use Legion.Stereotype, :model

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  alias Legion.Identity.Information.Registration, as: User

  schema "insecure_authentication_pairs" do
    belongs_to :user, User
    field :username, :string
    field :password, :string, virtual: true
    field :password_digest, :string
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :username, :password])
    |> validate_required([:user_id, :username, :password])
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
end
