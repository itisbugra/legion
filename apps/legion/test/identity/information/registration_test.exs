defmodule Legion.Identity.Information.RegistrationTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Information.Registration

  @valid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Registration.changeset(%Registration{}, @valid_attrs)

    assert changeset.valid?
  end
end
