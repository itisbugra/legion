defmodule Legion.Identity.Telephony.PhoneNumberTest do
  @moduledoc false
  use Legion.DataCase

  import NaiveDateTime, only: [utc_now: 0, add: 2]

  alias Legion.Identity.Telephony.PhoneNumber

  @user_id 1
  @phone_number "+966558611111"
  @phone_type :work

  @valid_attrs %{user_id: @user_id,
                 number: @phone_number,
                 type: @phone_type,
                 ignored?: false,
                 safe?: true,
                 primed_at: add(utc_now(), 5)}

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

  test "changeset without ignored attribute" do
    assert PhoneNumber.changeset(%PhoneNumber{}, omit_field(:ignored?)).valid?
  end

  test "changeset without safe attribute" do
    assert PhoneNumber.changeset(%PhoneNumber{}, omit_field(:safe?)).valid?
  end

  test "changeset without prioritization timestamp" do
    assert PhoneNumber.changeset(%PhoneNumber{}, omit_field(:inserted_at)).valid?
  end

  test "changeset with invalid phone number" do
    params = Map.put(@valid_attrs, :number, "test")

    refute PhoneNumber.changeset(%PhoneNumber{}, params).valid?
  end

  test "changeset fails with default params" do
    refute PhoneNumber.changeset(%PhoneNumber{}).valid?
  end

  test "changeset passes if prioritization given to safe and contended" do
    params = 
      %{user_id: 1,
        number: @phone_number,
        type: @phone_type,
        ignored?: false,
        safe?: true,
        primed_at: add(utc_now(), 5)}

    assert PhoneNumber.changeset(%PhoneNumber{}, params).valid?
  end

  test "changeset fails if prioritization given to unsafe" do
    params = 
      %{user_id: @user_id,
        number: @phone_number,
        type: @phone_type,
        ignored?: false,
        safe?: false,
        primed_at: add(utc_now(), 5)}

    refute PhoneNumber.changeset(%PhoneNumber{}, params).valid?
  end

  test "changeset fails if prioritization given to ignored" do
    params = 
      %{user_id: @user_id,
        number: @phone_number,
        type: @phone_type,
        ignored?: true,
        safe?: true,
        primed_at: add(utc_now(), 5)}

    refute PhoneNumber.changeset(%PhoneNumber{}, params).valid?
  end

  @tag :regression
  test "changeset fails if prioritization given unsafe and ignored" do
    params = 
      %{user_id: @user_id,
        number: @phone_number,
        type: @phone_type,
        ignored?: true,
        safe?: false,
        primed_at: add(utc_now(), 5)}

    refute PhoneNumber.changeset(%PhoneNumber{}, params).valid?
  end

  defp omit_field(field),
    do: Map.delete(@valid_attrs, field)
end