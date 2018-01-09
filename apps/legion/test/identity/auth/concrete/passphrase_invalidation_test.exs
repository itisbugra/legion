defmodule Legion.Identity.Auth.Concrete.Passphrase.InvalidationTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Auth.Concrete.Passphrase.Invalidation

  @valid_attrs %{passphrase_id: 1,
                 user_id: 1}

  test "changeset with valid attributes" do
    changeset = Invalidation.changeset(%Invalidation{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset without passphrase identifier" do
    changeset = Invalidation.changeset(%Invalidation{}, %{user_id: 1})

    refute changeset.valid?
  end

  test "changeset without user identifier" do
    changeset = Invalidation.changeset(%Invalidation{}, %{passphrase_id: 1})

    refute changeset.valid?
  end
end
