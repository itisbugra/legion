defmodule Legion.Identity.Telephony.PhoneNumber do
  @moduledoc """
  Represents a phone number entry of a user.

  ## Schema fields

  - `:user_id`: The reference of the user that phone number belongs to.
  - `:number`: The number of the phone.
  - `:type`: The type of the phone, e.g. "home", "work".
  - `:ignored?`: If `true`, the phone number will be hidden from transactional endpoints.
  - `:safe?`: If `false`, the phone number will not be used in authentication processes.
  - `:primed_at`: When the user marks the phone number entry as "primary", this attribute will be updated with a timestamp.
  - `:inserted_at`: The timestamp user created the entry.

  ## Prioritization of entries

  Phone number entries can be prioritized by a user, possibly for telephony-related transactional operations.
  A user may make phone number on a arbitrary moment.
  If no phone number of a user was made primary, the phone number will be picked according to configuration
  options.
  However, no matter what, the rules below for determining the phone number will still apply.

  If a phone number is primary,

  - the phone number is *not ignored*,
  - it should have no descendants with a higher insertion timestamp,
  - it should have no descendants with a higher prioritization timestamp,
  - its type is one of "home", "work", "mobile".

  ## Rules for prioritization

  Certain rules apply for the prioritization of the phone numbers.
  A phone number entry can be prioritized if and only if,

  - it is not marked as ignored,
  - it is marked as safe.
  """
  use Legion.Stereotype, :model

  import Legion.Telephony.PhoneNumber, only: [is_valid_number?: 1]

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Identity.Telephony.PhoneType

  @typedoc """
  A positive integer uniquely identifying a phone number entity.
  """
  @type id() :: pos_integer()

  @typedoc """
  Type of the phone number.
  """
  @type phone_type() :: :home | :mobile | :work | :home_fax | :work_fax | :pager

  schema "user_phone_numbers" do
    belongs_to :user, User
    field :number, :string
    field :type, PhoneType
    field :ignored?, :boolean, default: false
    field :safe?, :boolean, default: true
    field :primed_at, :naive_datetime
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :number, :type, :ignored?, :safe?, :primed_at])
    |> validate_required([:user_id, :number, :type])
    |> validate_safety_constraint()
    |> validate_phone_number()
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id)
  end

  defp validate_safety_constraint(changeset) do
    safe? = get_field(changeset, :safe?, true)
    ignored? = get_field(changeset, :ignored?, false)
    primed_at = get_field(changeset, :primed_at)

    if not is_nil(primed_at) and (not safe? or ignored?) do
      changeset
      |> add_error(:primed_at, "cannot be prioritized if unsafe or ignored")
    else
      changeset
    end
  end

  defp validate_phone_number(changeset) do
    # Retrieve the phone number if changed and validate
    if phone_number = get_change(changeset, :number) do
      if is_valid_number?(phone_number) do
        changeset
      else
        add_error(changeset, :phone_number, "is invalid")
      end
    else
      changeset
    end
  end
end