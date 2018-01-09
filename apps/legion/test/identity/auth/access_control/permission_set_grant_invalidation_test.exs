defmodule Legion.Identity.Auth.AccessControl.PermissionSetGrant.InvalidationTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Auth.AccessControl.PermissionSetGrant.Invalidation

  @valid_attrs %{grant_id: 1, authority_id: 1}

  test "changeset with valid attributes" do
    changeset = Invalidation.changeset(%Invalidation{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset without identifier of targeted grant" do
    changeset = Invalidation.changeset(%Invalidation{}, %{authority_id: 1})

    refute changeset.valid?
  end

  test "changeset without identifier of invalidation authority" do
    changeset = Invalidation.changeset(%Invalidation{}, %{grant_id: 1})

    refute changeset.valid?
  end
end
