defmodule Legion.Identity.Telephony.PhoneNumber.SafetyTrait.Invalidation do
  @moduledoc """
  Invalidates a safety trait immediately.

  This is useful for marking a phone number, counted safe at the time, as unsafe.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Telephony.PhoneNumber.SafetyTrait
  alias Legion.Identity.Auth.Concrete.Passphrase

  schema "user_phone_number_safety_trait_invalidations" do
    belongs_to(:safety_trait, SafetyTrait)
    belongs_to(:authority, Passphrase)
    field(:inserted_at, :naive_datetime, read_after_writes: true)
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:safety_trait_id, :authority_id])
    |> validate_required([:safety_trait_id, :authority_id])
    |> foreign_key_constraint(:safety_trait_id)
    |> foreign_key_constraint(:authority_id)
    |> unique_constraint(:safety_trait_id)
  end
end
