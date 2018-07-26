defmodule Legion.Identity.Information.RegistrationTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Information.Registration

  @valid_attrs %{has_gps_telemetry_consent?: true}

  test "changeset with valid attributes" do
    changeset = Registration.changeset(%Registration{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset without telemetry consent approval" do
    changeset = Registration.changeset(%Registration{}, %{})

    assert changeset.valid?
  end

  test "changeset is valid with default params" do
    assert Registration.changeset(%Registration{}).valid?
  end
end
