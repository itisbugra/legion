defmodule Legion.Identity.Information.AddressBook.AddressTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Information.AddressBook.Address

  @env Application.get_env(:legion, Legion.Identity.Information.AddressBook)
  @name_len Keyword.fetch!(@env, :name_length)
  @description_len Keyword.fetch!(@env, :description_length)
  @state_len Keyword.fetch!(@env, :state_length)
  @city_len Keyword.fetch!(@env, :city_length)
  @neighborhood_len Keyword.fetch!(@env, :neighborhood_length)
  @zip_code_len Keyword.fetch!(@env, :zip_code_length)

  @valid_attrs %{user_id: 1,
                 type: :home,
                 name: random_string(@name_len),
                 description: random_string(@description_len),
                 state: random_string(@state_len),
                 city: random_string(@city_len),
                 neighborhood: random_string(@neighborhood_len),
                 zip_code: random_string(@zip_code_len),
                 location: %Postgrex.Point{x: 5, y: 4},
                 country_name: "saudi arabia"}

  test "changeset with valid attributes" do
    assert Address.changeset(%Address{}, @valid_attrs).valid?
  end

  test "changeset without user identifier" do
    refute Address.changeset(%Address{}, omit_param(:user_id)).valid?
  end

  test "changeset without name" do
    refute Address.changeset(%Address{}, omit_param(:name)).valid?
  end

  test "changeset without type" do
    refute Address.changeset(%Address{}, omit_param(:type)).valid?
  end

  test "changeset without description" do
    assert Address.changeset(%Address{}, omit_param(:description)).valid?
  end

  test "changeset without state" do
    assert Address.changeset(%Address{}, omit_param(:state)).valid?
  end

  test "changeset without city" do
    assert Address.changeset(%Address{}, omit_param(:city)).valid?
  end

  test "changeset without neighborhood" do
    assert Address.changeset(%Address{}, omit_param(:neighborhood)).valid?
  end

  test "changeset without zip code" do
    assert Address.changeset(%Address{}, omit_param(:zip_code)).valid?
  end

  test "changeset without country" do
    refute Address.changeset(%Address{}, omit_param(:country_name)).valid?
  end

  test "changeset without location" do
    assert Address.changeset(%Address{}, omit_param(:location)).valid?
  end

  test "changeset with default params" do
    refute Address.changeset(%Address{}).valid?
  end

  defp omit_param(param),
    do: Map.delete(@valid_attrs, param)
end