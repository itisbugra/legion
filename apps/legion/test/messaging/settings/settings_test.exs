defmodule Legion.Messaging.SettingsTest do
  @moduledoc false
  use Legion.DataCase

  import Legion.Messaging.Settings

  alias Legion.Messaging.Settings.RegistryEntry

  @value %{"field" => "some value"}
  @take_quantity 5

  setup do
    user = Factory.insert(:user)
    register = Factory.insert(:messaging_settings_register)

    %{user: user, key: register.key}
  end

  describe "put/3" do
    test "puts a new value to a specified key", %{user: user, key: key} do
      result = put(user, key, @value)

      assert result == :ok
      assert @value == Repo.get_by!(RegistryEntry, key: key).value
    end

    test "returns error if user does not exist", %{key: key} do
      result = put(-1, key, @value)

      assert result == {:error, :unavailable}
    end
  end

  describe "get/2" do
    test "retrieves registry value for the key", %{key: key} do
      registry_entry = Factory.insert(:messaging_settings_registry_entry, key: key)

      result = get(key)

      assert result == registry_entry.value
    end

    test "returns default if no value was set for the key", %{key: key} do
      assert get(key, :default) == :default
    end
  end

  describe "take_last/2" do
    test "retrieves latest values for the key", %{key: key} do
      registry_entry = Factory.insert_list(@take_quantity, :messaging_settings_registry_entry, key: key)

      result = take(key, @take_quantity)

      assert result == Enum.map(registry_entry, fn x -> {x.value, x.inserted_at} end)
    end

    test "retrieves all values for the key if number of values are lower", %{key: key} do
      quantity = 2
      _registry_entry = Factory.insert_list(quantity, :messaging_settings_registry_entry, key: key)

      result = take(key, @take_quantity)

      assert length(result) == quantity
    end

    test "retrieves only latest values for the key if number of values are higher", %{key: key} do
      quantity = 20
      _registry_entry = Factory.insert_list(quantity, :messaging_settings_registry_entry, key: key)

      result = take(key, @take_quantity)

      assert length(result) == @take_quantity
    end
  end
end
