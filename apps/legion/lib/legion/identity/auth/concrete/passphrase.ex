defmodule Legion.Identity.Auth.Concrete.Passphrase do
  @moduledoc """
  Passphrase (a.k.a. access token) is an artifact of a successful concrete authentication.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Registration

  schema "passphrases" do
    belongs_to :user, Registration
    field :passkey_digest
    field :inserted_at, :naive_datetime, read_after_writes: true
    belongs_to :invalidator, Registration
    field :invalidated_at, :naive_datetime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :passkey_digest])
    |> validate_required([:user_id, :passkey_digest])
  end
end
