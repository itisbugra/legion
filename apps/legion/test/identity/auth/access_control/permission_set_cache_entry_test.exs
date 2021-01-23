defmodule Legion.Identity.Auth.AccessControl.PermissionSetCacheEntryTest do
  @moduledoc false
  use Legion.DataCase

  import NaiveDateTime, only: [utc_now: 0]

  alias Legion.Identity.Auth.AccessControl.PermissionSetCacheEntry

  @env Application.get_env(:legion, Legion.Identity.Auth.AccessControl)
  @valid_params %{user_id: 2, permission_set_id: 4, valid_until: utc_now()}

  test "changeset with valid attributes" do
    changeset =
      PermissionSetCacheEntry.changeset(
        %PermissionSetCacheEntry{},
        @valid_params
      )

    assert changeset.valid?
  end

  test "changeset without user identifier" do
    changeset =
      PermissionSetCacheEntry.changeset(
        %PermissionSetCacheEntry{},
        %{permission_set_id: 2, valid_until: utc_now()}
      )

    refute changeset.valid?
  end

  test "changeest without permission set identifier" do
    changeset =
      PermissionSetCacheEntry.changeset(
        %PermissionSetCacheEntry{},
        %{user_id: 2, valid_until: utc_now()}
      )

    refute changeset.valid?
  end

  test "changeset without coherence timeout (not allowing infinite lifetime on grant)" do
    env = Keyword.put(@env, :allow_infinite_lifetime, false)
    :ok = Application.put_env(:legion, Legion.Identity.Auth.AccessControl, env)

    changeset =
      PermissionSetCacheEntry.changeset(
        %PermissionSetCacheEntry{},
        %{user_id: 2, permission_set_id: 3}
      )

    refute changeset.valid?
  end

  test "changeset without coherence timeout (allowing infinite lifetime on grant)" do
    env = Keyword.put(@env, :allow_infinite_lifetime, true)
    :ok = Application.put_env(:legion, Legion.Identity.Auth.AccessControl, env)

    changeset =
      PermissionSetCacheEntry.changeset(
        %PermissionSetCacheEntry{},
        %{user_id: 2, permission_set_id: 3}
      )

    assert changeset.valid?
  end

  test "changeset is not valid with default params either" do
    refute PermissionSetCacheEntry.changeset(%PermissionSetCacheEntry{}).valid?
  end
end
