defmodule Legion.Identity.Auth.AccessControl.PermissionSetTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Auth.AccessControl.PermissionSet

  @env Application.get_env(:legion, Legion.Identity.Auth.AccessControl)
  @name_length Keyword.fetch!(@env, :permission_set_name_length)
  @description_length Keyword.fetch!(@env, :permission_set_description_length)
  @valid_params %{
    name: "Default permission set",
    description: "Used by normal people.",
    user_id: 8
  }

  test "changeset with valid attributes" do
    changeset =
      PermissionSet.changeset(
        %PermissionSet{},
        @valid_params
      )

    assert changeset.valid?
  end

  test "changeset without name attribute" do
    changeset =
      PermissionSet.changeset(
        %PermissionSet{},
        %{description: "Used by normal people.", user_id: 8}
      )

    refute changeset.valid?
  end

  test "changeset without description attribute" do
    changeset =
      PermissionSet.changeset(
        %PermissionSet{},
        %{name: "Default permission set", user_id: 8}
      )

    refute changeset.valid?
  end

  test "changeset without user identifier attribute" do
    changeset =
      PermissionSet.changeset(
        %PermissionSet{},
        %{name: "Default permission set", description: "Used by normal people."}
      )

    refute changeset.valid?
  end

  test "changeset with name attribute shorter than #{Enum.min(@name_length)}" do
    changeset =
      PermissionSet.changeset(
        %PermissionSet{},
        %{
          name: genstr(Enum.min(@name_length) - 1),
          description: "Used by normal people.",
          user_id: 8
        }
      )

    refute changeset.valid?
  end

  test "changeset with name attribute longer than #{Enum.max(@name_length)}" do
    changeset =
      PermissionSet.changeset(
        %PermissionSet{},
        %{
          name: genstr(Enum.max(@name_length) + 1),
          description: "Used by normal people.",
          user_id: 8
        }
      )

    refute changeset.valid?
  end

  test "changeset with description attribute shorter than #{Enum.min(@description_length)}" do
    changeset =
      PermissionSet.changeset(
        %PermissionSet{},
        %{
          name: "Default permission set",
          description: genstr(Enum.min(@description_length) - 1),
          user_id: 8
        }
      )

    refute changeset.valid?
  end

  test "changeset with description attribute longer than #{Enum.max(@description_length)}" do
    changeset =
      PermissionSet.changeset(
        %PermissionSet{},
        %{
          name: "Default permission set",
          description: genstr(Enum.max(@description_length) + 1),
          user_id: 8
        }
      )

    refute changeset.valid?
  end

  test "changeset is not valid with default params either" do
    refute PermissionSet.changeset(%PermissionSet{}).valid?
  end

  defp genstr(len) do
    len
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
    |> binary_part(0, len)
  end
end
