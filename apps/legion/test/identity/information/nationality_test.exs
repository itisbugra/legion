defmodule Legion.Identity.Information.NationalityTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Information.Nationality

  test "changeset cannot be valid no matter what" do
    refute Nationality.changeset(
             %Nationality{},
             %{
               country_name: "turkey",
               preferred_demonym: "pd",
               second_demonym: "pd",
               third_demonym: "pd"
             }
           ).valid?
  end

  test "changeset cannot be valid with default struct either" do
    refute Nationality.changeset(%Nationality{}).valid?
  end
end
