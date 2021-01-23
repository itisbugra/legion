defmodule Legion.Identity.Auth.Concrete.Passphrase.InvalidationTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Auth.Concrete.Passphrase.Invalidation

  @valid_attrs %{source_passphrase_id: 1, target_passphrase_id: 1}

  test "changeset with valid attributes" do
    changeset = Invalidation.changeset(%Invalidation{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset without source passphrase identifier" do
    changeset = Invalidation.changeset(%Invalidation{}, %{target_passphrase_id: 1})

    refute changeset.valid?
  end

  test "changeset without target passphrase identifier" do
    changeset = Invalidation.changeset(%Invalidation{}, %{source_passphrase_id: 1})

    refute changeset.valid?
  end

  test "changeset is not valid with default params either" do
    refute Invalidation.changeset(%Invalidation{}).valid?
  end
end
