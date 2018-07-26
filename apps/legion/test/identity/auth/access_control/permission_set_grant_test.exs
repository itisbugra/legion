defmodule Legion.Identity.Auth.AccessControl.PermissionSetGrantTest do
  use Legion.DataCase

  import NaiveDateTime, only: [add: 2, utc_now: 0]

  alias Legion.Identity.Auth.AccessControl.PermissionSetGrant

  @env Application.get_env(:legion, Legion.Identity.Auth.AccessControl)
  @valid_params %{permission_set_id: 1,
                  grantee_id: 2,
                  authority_id: 3,
                  valid_after: 2,
                  valid_for: 4}

  test "changeset with valid attributes" do
    changeset = 
      PermissionSetGrant.changeset(%PermissionSetGrant{},
                                   @valid_params)

    assert changeset.valid?
  end

  test "changeset without permission set identifier" do
    changeset =
      PermissionSetGrant.changeset(%PermissionSetGrant{},
                                   %{grantee_id: 2,
                                     authority_id: 3,
                                     valid_after: 2,
                                     valid_for: 4})

    refute changeset.valid?
  end

  test "changeset without grantee identifier" do
    changeset =
      PermissionSetGrant.changeset(%PermissionSetGrant{},
                                  %{permission_set_id: 1,
                                    authority_id: 3,
                                    valid_after: 2,
                                    valid_for: 4})

    refute changeset.valid?
  end

  test "changeset without authority identifier" do
    changeset =
      PermissionSetGrant.changeset(%PermissionSetGrant{},
                                   %{permission_set_id: 1,
                                     grantee_id: 2,
                                     valid_after: 2,
                                     valid_for: 4})

    refute changeset.valid?
  end

  test "changeset without validation deferral" do
    changeset =
      PermissionSetGrant.changeset(%PermissionSetGrant{},
                                   %{permission_set_id: 1,
                                     grantee_id: 2,
                                     authority_id: 3,
                                     valid_after: 2,
                                     valid_for: 2})

    assert changeset.valid?
  end

  test "changeset without lifetime (not allowing infinite lifetime)" do
    new_env = Keyword.put(@env, :allow_infinite_lifetime, false)
    Application.put_env(:legion, Legion.Identity.Auth.AccessControl, new_env, persistent: true)

    changeset =
      PermissionSetGrant.changeset(%PermissionSetGrant{},
                                   %{permission_set_id: 1,
                                     grantee_id: 2,
                                     authority_id: 3,
                                     valid_after: 2})

    refute changeset.valid?
  end

  test "changeset without lifetime (allowing infinite lifetime)" do
    new_env = Keyword.put(@env, :allow_infinite_lifetime, false)
    Application.put_env(:legion, Legion.Identity.Auth.AccessControl, new_env)

    changeset =
      PermissionSetGrant.changeset(%PermissionSetGrant{},
                                   %{permission_set_id: 1,
                                     grantee_id: 2,
                                     authority_id: 3,
                                     valid_after: 2,
                                     valid_for: 4})

    assert changeset.valid?
  end

  test "changeset having same grantee and authority identifiers" do
    changeset =
      PermissionSetGrant.changeset(%PermissionSetGrant{},
                                   %{permission_set_id: 1,
                                     grantee_id: 2,
                                     authority_id: 2,
                                     valid_after: 2,
                                     valid_for: 2})

    refute changeset.valid?
    assert List.first(changeset.errors) == {:second, {"is equal to grantee_id", [value: 2]}}
  end

  test "changeset is not valid with default params either" do
    refute PermissionSetGrant.changeset(%PermissionSetGrant{}).valid?
  end

  test "validate/1 returns ok if grant is valid" do
    grant = 
      %PermissionSetGrant{permission_set_id: 1,
                          grantee_id: 2,
                          authority_id: 3,
                          valid_after: 0,
                          valid_for: 200_000,
                          inserted_at: utc_now(),
                          invalidation: nil}

    assert PermissionSetGrant.validate(grant) == :ok
  end

  test "validate/1 returns error if grant is timed out" do
    grant = 
      %PermissionSetGrant{permission_set_id: 1,
                          grantee_id: 2,
                          authority_id: 3,
                          valid_after: 0,
                          valid_for: 200_000,
                          inserted_at: add(utc_now(), -400_000),
                          invalidation: nil}

    assert PermissionSetGrant.validate(grant) == {:error, :timed_out}
  end

  test "validate/1 returns error if grant is invalidated manually" do
    invalidation = 
      %PermissionSetGrant.Invalidation{id: 2,
                                       grant_id: 1,
                                       authority_id: 2}

    grant = 
      %PermissionSetGrant{id: 1,
                          permission_set_id: 1,
                          grantee_id: 2,
                          authority_id: 3,
                          valid_after: 0,
                          valid_for: 200_000,
                          inserted_at: utc_now(),
                          invalidation: invalidation}

    assert PermissionSetGrant.validate(grant) == {:error, :invalid}
  end

  test "validate/1 returns error if grant has not gone active yet" do
    grant = 
      %PermissionSetGrant{permission_set_id: 1,
                          grantee_id: 2,
                          authority_id: 3,
                          valid_after: 200_000,
                          valid_for: 200_000,
                          inserted_at: utc_now(),
                          invalidation: nil}

    assert PermissionSetGrant.validate(grant) == {:error, :inactive}
  end

  test "validate/1 returns ok if grant has no validation deferral" do
    grant = 
      %PermissionSetGrant{permission_set_id: 1,
                          grantee_id: 2,
                          authority_id: 3,
                          valid_for: 200_000,
                          inserted_at: utc_now(),
                          invalidation: nil}

    assert PermissionSetGrant.validate(grant) == :ok
  end
end
