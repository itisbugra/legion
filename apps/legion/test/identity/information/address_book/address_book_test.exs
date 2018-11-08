defmodule Legion.Identity.Information.AddressBookTest do
  @moduledoc false
  use Legion.DataCase

  import Legion.Identity.Information.AddressBook

  alias Legion.Identity.Information.AddressBook.Address

  @env Application.get_env(:legion, Legion.Identity.Information.AddressBook)
  @listing_default_page_size Keyword.fetch!(@env, :listing_default_page_size)

  @insert_volume @listing_default_page_size * 6

  setup do
    user = Factory.insert(:user)
    addresses = Factory.insert_list(@insert_volume, :address, user: user)
    ids = Enum.map(addresses, & &1.id)

    unknown = Factory.insert(:user)
    _obsoletes = Factory.insert_list(@insert_volume, :address, user: unknown)

    %{user: user, addresses: addresses, ids: ids}
  end

  describe "list_addresses_of_user/2" do
    test "lists addresses of a user", %{user: user, ids: ids} do
      listed = list_addresses_of_user(user.id)

      # Every element is a member of factorized addresses list
      assert Enum.all?(listed, &Enum.member?(ids, &1.id))
      assert length(listed) == @listing_default_page_size
    end

    test "returns empty list if user does not have any address" do
      user = Factory.insert(:user)

      assert list_addresses_of_user(user.id) == []
    end

    test "returns given number of entities in presence of limit", %{user: user, ids: ids} do
      listed = list_addresses_of_user(user.id, limit: @listing_default_page_size - 1)

      assert Enum.all?(listed, &Enum.member?(ids, &1.id))
      assert length(listed) == @listing_default_page_size - 1
    end

    test "limit is fenced by the default value", %{user: user, ids: ids} do
      listed = list_addresses_of_user(user.id, limit: @listing_default_page_size + 1)

      assert Enum.all?(listed, &Enum.member?(ids, &1.id))
      assert length(listed) == @listing_default_page_size
    end
  end

  describe "delete_address!/1" do
    test "deletes an existing address", %{addresses: addresses} do
      address = hd(addresses)

      delete_address!(address.id)

      refute Repo.get_by(Address, id: address.id)
    end

    test "throws if address does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        delete_address!(-1)
      end
    end
  end

  describe "create_address/5" do
    test "adds new address of user", %{user: user} do
      result = create_address(user.id, :work, "new addr", "turkey", city: "Istanbul")

      assert match?({:ok, _}, result)
    end

    test "inserts new address of user", %{user: user} do
      {:ok, address} = create_address(user.id, :work, "new addr", "turkey", city: "Istanbul")

      assert Repo.get_by(Address, id: address.id)
    end

    test "returns error if data is not valid", %{user: user} do
      result = create_address(user.id, :invalid, "new addr", "turkey", city: "Istanbul")

      assert match?({:error, _}, result)
    end

    test "does not insert if data is not valid", %{user: user} do
      create_address(user.id, :invalid, "new addr", "turkey", city: "Istanbul")

      refute Repo.get_by(Address, name: "new addr")
    end

    test "creates address with default params", %{user: user} do
      result = create_address(user.id, :work, "new addr", "turkey")

      assert match?({:ok, _}, result)
    end
  end

  describe "update_address/5" do
    test "updates an existing address of user", %{addresses: addresses} do
      address = hd(addresses)
      result = update_address(address.id, :home, "new addr", "turkey", city: "Istanbul")

      assert match?({:ok, _}, result)
    end

    test "upserts an existing address of user", %{addresses: addresses} do
      address = hd(addresses)
      update_address(address.id, :home, "new addr", "turkey", city: "Istanbul")

      updated = Repo.get_by(Address, id: address.id)

      assert updated.name == "new addr"
    end

    test "returns error if new data is not valid", %{addresses: addresses} do
      address = hd(addresses)
      result = update_address(address.id, :invalid, "new addr", "turkey", city: "Istanbul")

      assert match?({:error, _}, result)
    end

    test "does not update if data is not valid", %{addresses: addresses} do
      address = hd(addresses)
      update_address(address.id, :invalid, "new addr", "turkey", city: "Istanbul")

      updated = Repo.get_by(Address, id: address.id)

      refute updated.name == "new addr"
    end

    test "updates address with default params", %{addresses: addresses} do
      address = hd(addresses)
      result = update_address(address.id, :work, "new addr", "turkey")

      assert match?({:ok, %Address{name: "new addr"}}, result)
    end
  end
end
