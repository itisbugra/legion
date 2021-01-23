defmodule Legion.Identity.Information.Political.IntermediateRegionTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Information.Political.IntermediateRegion

  @attr %{name: "name", subregion_name: "subregion_name", code: 123_456}

  test "changeset will error no matter what" do
    refute IntermediateRegion.changeset(%IntermediateRegion{}, @attr).valid?
  end

  test "changeset will not succeed with default params either" do
    refute IntermediateRegion.changeset(%IntermediateRegion{}).valid?
  end
end
