defmodule Legion.Identity.Information.Political.RegionTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Information.Political.Region

  @attr %{name: "name", code: 1234}

  test "changeset will error no matter what" do
    refute Region.changeset(%Region{}, @attr).valid?
  end

  test "changeset will not succeed with default params either" do
    refute Region.changeset(%Region{}).valid?
  end
end
