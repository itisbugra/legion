defmodule Legion.Identity.Information.Political.SubregionTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Information.Political.Subregion

  @attr %{name: "name", region_name: "region_name", code: 123_456}

  test "changeset will error no matter what" do
    refute Subregion.changeset(%Subregion{}, @attr).valid?
  end

  test "changeset will not succeed with default params either" do
    refute Subregion.changeset(%Subregion{}).valid?
  end
end
