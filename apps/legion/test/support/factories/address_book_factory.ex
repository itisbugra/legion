defmodule Legion.Identity.Information.AddressBook.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Legion.Repo

  defmacro __using__(_opts) do
    quote do
      def address_factory do
        alias Legion.Identity.Information.AddressBook.Address
        alias Legion.Identity.Information.AddressBook.AddressType

        %Address{
          user: build(:user),
          type: :home,
          name: sequence(:address_name, &"address_name_#{&1}"),
          description: sequence(:address_description, &"address_description_#{&1}"),
          state: sequence(:address_state, &"address_state_#{&1}"),
          city: sequence(:address_city, &"address_city_#{&1}"),
          neighborhood: sequence(:address_neighborhood, &"address_neighborhood_#{&1}"),
          zip_code: sequence(:address_zip_code, &"address_zip_code_#{&1}"),
          location:
            sequence(:address_location, &%Postgrex.Point{x: rem(&1, 180), y: rem(&1, 180)}),
          country_name: "turkey"
        }
      end
    end
  end
end
