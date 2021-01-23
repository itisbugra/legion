defmodule Legion.Identity.Telephony.Stub do
  @moduledoc """
  Defines stubs for convenient unit testing of telephony modules.
  """

  @doc """
  Defines a case for telephony tests.

  Setups the environment with following map keys:

  - `:number`: A phone number string.
  - `:owner`: Owner of the generated phone numbers.
  - `:authority`: Authority of the actions.
  - `:owner_passphrase`: Passphrase of the `:owner`.
  - `:authority_passphrase`: Passphrase of the `:authority`. 
  - `:safe`: Phone number marked as safe.
  - `:safe_but_ignored`: Phone number marked as both safe and ignored.
  - `:unsafe`: Phone number marked as unsafe.
  - `:unsafe_and_ignored`: Phone number marked as both unsafe and ignored.
  - `:safe_and_prioritized`: Phone number marked as safe and prioritized.
  - `:safe_and_overprioritized`: Phone number marked as safe but overprioritized by another number.
  """
  alias Legion.Factory

  @phone_number "+966558611111"

  def scaffold_stubs do
    owner = Factory.insert(:user)
    authority = Factory.insert(:user)

    owner_passphrase = Factory.insert(:passphrase, user: owner)
    authority_passphrase = Factory.insert(:passphrase, user: authority)

    # Safe
    safe = Factory.insert(:phone_number, user: owner)
    Factory.insert(:phone_number_safety_trait, phone_number: safe, authority: owner_passphrase)

    # Safe but ignored
    safe_but_ignored = Factory.insert(:phone_number, user: owner)

    Factory.insert(:phone_number_safety_trait,
      phone_number: safe_but_ignored,
      authority: owner_passphrase
    )

    Factory.insert(:phone_number_neglection_trait,
      phone_number: safe_but_ignored,
      authority: authority_passphrase
    )

    # Unsafe
    unsafe = Factory.insert(:phone_number, user: owner)

    # Unsafe and ignored
    unsafe_and_ignored = Factory.insert(:phone_number, user: owner)

    Factory.insert(:phone_number_neglection_trait,
      phone_number: unsafe_and_ignored,
      authority: owner_passphrase
    )

    # Safe and prioritized
    safe_and_prioritized_owner = Factory.insert(:user)
    safe_and_prioritized = Factory.insert(:phone_number, user: safe_and_prioritized_owner)

    Factory.insert(:phone_number_safety_trait,
      phone_number: safe_and_prioritized,
      authority: owner_passphrase
    )

    Factory.insert(:phone_number_prioritization_trait,
      phone_number: safe_and_prioritized,
      authority: authority_passphrase
    )

    # Safe and overprioritized
    safe_and_overprioritized_owner = Factory.insert(:user)
    safe_and_overprioritized = Factory.insert(:phone_number, user: safe_and_overprioritized_owner)

    Factory.insert(:phone_number_safety_trait,
      phone_number: safe_and_overprioritized,
      authority: owner_passphrase
    )

    Factory.insert(:phone_number_prioritization_trait,
      phone_number: safe_and_overprioritized,
      authority: authority_passphrase
    )

    overprioritizing = Factory.insert(:phone_number, user: safe_and_overprioritized_owner)

    Factory.insert(:phone_number_safety_trait,
      phone_number: overprioritizing,
      authority: owner_passphrase
    )

    Factory.insert(:phone_number_prioritization_trait,
      phone_number: overprioritizing,
      authority: authority_passphrase
    )

    %{
      owner: owner,
      authority: authority,
      owner_passphrase: owner_passphrase,
      authority_passphrase: authority_passphrase,
      safe: safe,
      safe_but_ignored: safe_but_ignored,
      unsafe: unsafe,
      safe_and_prioritized: safe_and_prioritized,
      safe_and_overprioritized: safe_and_overprioritized,
      number: @phone_number
    }
  end
end
