defmodule Legion.Identity.Information.Political.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Legion.Repo

  defmacro __using__(_opts) do
    quote do
      alias Legion.Identity.Information.Political.{Region, Subregion, IntermediateRegion, Country}

      def region_factory do
        %Region{
          name: sequence(:region_name, &"region_name_#{&1}"),
          code: sequence(:region_code, &rem(&1, 2048))
        }
      end

      def subregion_factory do
        %Subregion{
          name: sequence(:subregion_name, &"subregion_name_#{&1}"),
          code: sequence(:subregion_code, &rem(&1, 2048)),
          region_name: build(:region)
        }
      end

      def intermediate_region_factory do
        %IntermediateRegion{
          name: sequence(:intermediate_region_name, &"intermediate_region_name_#{&1}"),
          code: sequence(:intermediate_region_code, &rem(&1, 2048)),
          subregion: build(:subregion)
        }
      end

      def country_factory do
        %Country{
          name: sequence(:country_name, &"country_name_#{&1}"),
          two_letter: "aa",
          three_letter: "aaa",
          iso_3166: "ISO 3166-2:XX",
          region_name: "europe",
          subregion_name: "northern europe",
          intermediate_region_name: "channel islands"
        }
      end
    end
  end
end
