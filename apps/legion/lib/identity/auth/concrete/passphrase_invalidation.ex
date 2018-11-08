defmodule Legion.Identity.Auth.Concrete.Passphrase.Invalidation do
  @moduledoc """
  Manual invalidation of passphrases.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Auth.Concrete.Passphrase
  alias Legion.Identity.Auth.Concrete.Passphrase.Invalidation

  schema "passphrase_invalidations" do
    belongs_to(:source_passphrase, Passphrase)
    belongs_to(:target_passphrase, Passphrase)
    field(:inserted_at, :naive_datetime, read_after_writes: true)
  end

  @spec changeset(Invalidation, map) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:source_passphrase_id, :target_passphrase_id])
    |> validate_required([:source_passphrase_id, :target_passphrase_id])
    |> foreign_key_constraint(:source_passphrase_id)
    |> foreign_key_constraint(:target_passphrase_id)
    |> unique_constraint(:target_passphrase_id)
  end
end
