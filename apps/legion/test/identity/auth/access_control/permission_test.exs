defmodule Legion.Identity.Auth.AccessControl.PermissionTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Auth.AccessControl.Permission

  @valid_params %{
    controller_name: Atom.to_string(__MODULE__),
    controller_action: :index,
    type: "all"
  }

  test "changeset with valid attributes" do
    changeset = Permission.changeset(%Permission{}, @valid_params)

    assert changeset.valid?
  end

  test "changeset without controller name attribute" do
    changeset =
      Permission.changeset(
        %Permission{},
        %{controller_action: :index, type: "all"}
      )

    refute changeset.valid?
  end

  test "changeset without controller action attribute" do
    changeset =
      Permission.changeset(
        %Permission{},
        %{controller_name: Atom.to_string(__MODULE__), type: "all"}
      )

    refute changeset.valid?
  end

  test "changeset without type attribute" do
    changeset =
      Permission.changeset(
        %Permission{},
        %{controller_name: Atom.to_string(__MODULE__), controller_action: :index}
      )

    refute changeset.valid?
  end

  test "changeset is not valid with default params either" do
    refute Permission.changeset(%Permission{}).valid?
  end
end
