defmodule Legion.Identity.Auth.Concrete.Passphrase.Invalidation do
  @moduledoc """
  Manual invalidation of passphrases.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Auth.Concrete.Passphrase
  alias Legion.Identity.Auth.Concrete.Passphrase.Invalidation
  alias Legion.Identity.Information.Registration

  schema "passphrase_invalidations" do
    belongs_to :passphrase, Passphrase
    belongs_to :user, Registration
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  @spec changeset(Invalidation, map) :: Ecto.Changeset.t 
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:passphrase_id, :user_id])
    |> validate_required([:passphrase_id, :user_id])
    |> foreign_key_constraint(:passphrase_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:passphrase_id)
  end
end
