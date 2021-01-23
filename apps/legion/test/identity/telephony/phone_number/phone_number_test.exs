defmodule Legion.Identity.Telephony.PhoneNumberTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Identity.Telephony.PhoneNumber

  @user_id 1
  @phone_number "+966558611111"
  @phone_type :work

  @valid_attrs %{user_id: @user_id,
                 number: @phone_number,
                 type: @phone_type}

  test "changeset with valid attrs" do
    assert PhoneNumber.changeset(%PhoneNumber{}, @valid_attrs).valid?
  end

  test "changeset without number" do
    refute PhoneNumber.changeset(%PhoneNumber{}, omit_field(:number)).valid?
  end

  test "changeset without type" do
    refute PhoneNumber.changeset(%PhoneNumber{}, omit_field(:type)).valid?
  end

  test "changeset without user identifier" do
    refute PhoneNumber.changeset(%PhoneNumber{}, omit_field(:user_id)).valid?
  end

  test "changeset with invalid phone number" do
    params = Map.put(@valid_attrs, :number, "test")

    refute PhoneNumber.changeset(%PhoneNumber{}, params).valid?
  end

  test "changeset fails with default params" do
    refute PhoneNumber.changeset(%PhoneNumber{}).valid?
  end

  defp omit_field(field),
    do: Map.delete(@valid_attrs, field)
end