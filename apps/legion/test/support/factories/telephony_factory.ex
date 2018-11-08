defmodule Legion.Identity.Information.Telephony.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Legion.Repo

  defmacro __using__(_opts) do
    quote do
      alias Legion.Identity.Telephony.PhoneNumber

      alias Legion.Identity.Telephony.PhoneNumber.{
        PrioritizationTrait,
        SafetyTrait,
        NeglectionTrait
      }

      @six_months 60 * 60 * 24 * 180

      def phone_number_factory do
        %PhoneNumber{
          user: build(:user),
          number: sequence(:phone_number_number, &"#{rem(&1, 99_999_999) + 99_999_999}"),
          type: :work
        }
      end

      def phone_number_prioritization_trait_factory do
        %PrioritizationTrait{phone_number: build(:phone_number), authority: build(:passphrase)}
      end

      def phone_number_safety_trait_factory do
        %SafetyTrait{
          phone_number: build(:phone_number),
          authority: build(:passphrase),
          valid_for: @six_months
        }
      end

      def phone_number_neglection_trait_factory do
        %NeglectionTrait{phone_number: build(:phone_number), authority: build(:passphrase)}
      end
    end
  end
end
