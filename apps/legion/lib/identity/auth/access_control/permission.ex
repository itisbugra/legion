defmodule Legion.Identity.Auth.AccessControl.Permission do
  @moduledoc """
  Permissions.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Auth.AccessControl.PermissionSet
  alias Legion.Identity.Auth.AccessControl.ControllerAction

  schema "permissions" do
    field(:controller_name, :string)
    field(:controller_action, ControllerAction)
    field(:type, :string)

    many_to_many(
      :permission_sets,
      PermissionSet,
      join_through: "permission_set_permissions"
    )
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:controller_name, :controller_action, :type])
    |> validate_required([:controller_name, :controller_action, :type])
  end
end
