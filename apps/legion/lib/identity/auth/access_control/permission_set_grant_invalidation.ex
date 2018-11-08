defmodule Legion.Identity.Auth.AccessControl.PermissionSetGrant.Invalidation do
  @moduledoc """
  Represents an invalidation order of permission set grant.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Auth.AccessControl.PermissionSetGrant
  alias Legion.Identity.Information.Registration

  schema "permission_set_grant_invalidations" do
    belongs_to(:grant, PermissionSetGrant)
    belongs_to(:authority, Registration)
    field(:inserted_at, :naive_datetime, read_after_writes: true)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:grant_id, :authority_id])
    |> validate_required([:grant_id, :authority_id])
    |> foreign_key_constraint(:grant_id)
    |> foreign_key_constraint(:authority_id)
    |> unique_constraint(:grant_id)
  end
end
