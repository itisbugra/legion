defmodule Legion.Identity.Information.Telephony.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Legion.Repo

  defmacro __using__(_opts) do
    quote do
      alias Legion.Identity.Telephony.PhoneNumber

      def phone_number_factory do
        %PhoneNumber{user: build(:user),
                     number: sequence(:phone_number_number, &"#{rem(&1, 99999999) + 99999999}"),
                     type: :work,
                     ignored?: false,
                     safe?: true,}
      end
    end
  end
end