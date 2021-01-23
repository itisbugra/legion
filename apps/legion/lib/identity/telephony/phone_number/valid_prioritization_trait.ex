defmodule Legion.Identity.Telephony.PhoneNumber.ValidPrioritizationTrait do
  @moduledoc """
  A view for the prioritization traits filtering only valid ones.
  """
  use Legion.Stereotype, :viewdecl

  alias Legion.Identity.Telephony.PhoneNumber
  alias Legion.Identity.Auth.Concrete.Passphrase

  create do
    """
    CREATE OR REPLACE VIEW user_phone_number_valid_prioritization_traits AS
      WITH upnpt_lat AS (
        -- denormalized CTE
        SELECT upnpt.*, upn.user_id
        FROM user_phone_number_prioritization_traits upnpt
        INNER JOIN user_phone_numbers upn ON
            upn.id = upnpt.phone_number_id
      )
      SELECT l1.id, l1.phone_number_id, l1.authority_id, l1.inserted_at
      FROM upnpt_lat l1
      LEFT OUTER JOIN upnpt_lat l2 ON
        l1.user_id = l2.user_id AND
        l1.id < l2.id
      WHERE l2.id IS NULL;
    """
  end

  drop do
    """
    DROP VIEW user_phone_number_valid_prioritization_traits;
    """
  end

  schema "user_phone_number_valid_prioritization_traits" do
    belongs_to :phone_number, PhoneNumber
    belongs_to :authority, Passphrase
    field :inserted_at, :naive_datetime_usec
  end
end
