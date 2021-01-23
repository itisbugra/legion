defmodule Legion.Identity.Telephony.PhoneNumber.SafetyTrait do
  @moduledoc """
  Marks a phone number as safe for given amount of time.

  Defines a normalized event sink for trust actions.

  # Schema fields

  - `:phone_number`: The phone number being affected from the safety trait.
  - `:authority`: The authority who created the safety trait.
  - `:valid_for`: The duration the safety trait is valid for, in seconds.
  - `:inserted_at`: The timestamp of the safety trait, immutable.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Telephony.PhoneNumber
  alias Legion.Identity.Telephony.PhoneNumber.SafetyTrait.Invalidation
  alias Legion.Identity.Auth.Concrete.Passphrase

  @zero 0

  @env Application.get_env(:legion, Legion.Identity.Telephony.PhoneNumber)
  @initial_safe_duration Keyword.fetch!(@env, :initial_safe_duration)
  @maximum_valid_duration Keyword.fetch!(@env, :maximum_safe_duration)

  schema "user_phone_number_safety_traits" do
    belongs_to :phone_number, PhoneNumber
    belongs_to :authority, Passphrase
    field :valid_for, :integer, default: @initial_safe_duration
    field :inserted_at, :naive_datetime_usec, read_after_writes: true

    has_one :invalidation, Invalidation
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:phone_number_id, :authority_id, :valid_for])
    |> validate_required([:phone_number_id, :authority_id])
    |> validate_number(:valid_for, greater_than: @zero, less_than: @maximum_valid_duration)
    |> foreign_key_constraint(:phone_number_id)
    |> foreign_key_constraint(:authority_id)
  end
end
