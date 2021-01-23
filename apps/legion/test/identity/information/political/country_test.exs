defmodule Legion.Identity.Information.Political.CountryTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Information.Political.Country

  @attr %{
    name: "name",
    two_letter: "tw",
    three_letter: "thr",
    iso_3166: "ISO 3166-2:AF",
    region_name: "region_name",
    subregion_name: "subregion_name",
    intermediate_region_name: "intermediate_region_name"
  }

  test "changeset will error no matter what" do
    refute Country.changeset(%Country{}, @attr).valid?
  end

  test "changeset will not succeed with default params either" do
    refute Country.changeset(%Country{}).valid?
  end
end
