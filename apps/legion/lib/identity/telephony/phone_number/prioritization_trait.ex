defmodule Legion.Identity.Telephony.PhoneNumber.PrioritizationTrait do
  @moduledoc """
  Prioritizes a phone number upon grant.

  Defines a normalized event sink for prioritization actions.

  # Schema fields

  - `:phone_number`: The phone number being affected from the prioritization trait.
  - `:authority`: The authority who prioritized the phone number.
  - `:inserted_at`: The timestamp of the prioritization trait, immutable.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Telephony.PhoneNumber
  alias Legion.Identity.Auth.Concrete.Passphrase

  schema "user_phone_number_prioritization_traits" do
    belongs_to :phone_number, PhoneNumber
    belongs_to :authority, Passphrase
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:phone_number_id, :authority_id])
    |> validate_required([:phone_number_id, :authority_id])
    |> foreign_key_constraint(:phone_number_id)
    |> foreign_key_constraint(:authority_id)
    |> unique_constraint(:phone_number_id)
  end
end