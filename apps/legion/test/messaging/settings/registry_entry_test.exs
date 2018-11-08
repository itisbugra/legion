defmodule Legion.Messaging.Settings.RegistryEntryTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Messaging.Settings.RegistryEntry

  @key "Some.key"
  @value Map.new()
  @valid_params %{key: @key, value: @value, authority_id: 1}

  test "changeset with valid attributes" do
    changeset = RegistryEntry.changeset(%RegistryEntry{}, @valid_params)

    assert changeset.valid?
  end

  test "changeset without key" do
    changeset =
      RegistryEntry.changeset(
        %RegistryEntry{},
        %{value: @value, authority_id: 1}
      )

    refute changeset.valid?
  end

  test "changeset without value" do
    changeset =
      RegistryEntry.changeset(
        %RegistryEntry{},
        %{key: @key, authority_id: 1}
      )

    refute changeset.valid?
  end

  test "changeset without authority identifier" do
    changeset =
      RegistryEntry.changeset(
        %RegistryEntry{},
        %{key: @key, value: @value}
      )

    refute changeset.valid?
  end
end
