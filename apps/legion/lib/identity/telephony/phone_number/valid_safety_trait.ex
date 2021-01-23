defmodule Legion.Identity.Telephony.PhoneNumber.ValidSafetyTrait do
  @moduledoc """
  A view for the safety traits of phone numbers filtering only valid ones.
  """
  use Legion.Stereotype, :viewdecl

  alias Legion.Identity.Telephony.PhoneNumber
  alias Legion.Identity.Auth.Concrete.Passphrase

  create do
    """
    CREATE OR REPLACE VIEW user_phone_number_valid_safety_traits AS
      SELECT *
      FROM user_phone_number_safety_traits upnst
      WHERE (upnst.inserted_at + upnst.valid_for * '1 second'::interval) > now();
    """
  end

  drop do
    """
    DROP VIEW user_phone_number_valid_safety_traits;
    """
  end

  schema "user_phone_number_valid_safety_traits" do
    belongs_to :phone_number, PhoneNumber
    belongs_to :authority, Passphrase
    field :valid_for, :integer
    field :inserted_at, :naive_datetime_usec
  end
end
