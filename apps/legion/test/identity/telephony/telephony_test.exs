defmodule Legion.Identity.TelephonyTest do
  @moduledoc false
  use Legion.DataCase

  import Legion.Identity.Telephony

  alias Legion.Identity.Telephony.PhoneNumber

  @phone_number "+966558611111"
  @changed_phone_number "+966558611112"

  @fixture_size 5

  setup do
    user = Factory.insert(:user)
    pnrs = Factory.insert_list(@fixture_size, :phone_number, user: user)

    ign = Factory.insert(:phone_number, user: user, ignored?: true)
    uns = Factory.insert(:phone_number, user: user, safe?: false)

    %{user: user,
      phone_numbers: pnrs,
      phone_number: hd(pnrs),
      ignored: ign,
      unsafe: uns,
      number: @phone_number}
  end

  describe "create_phone_number/4" do
    test "creates a phone number with default options", %{user: u} do
      assert match? {:ok, _}, create_phone_number(u.id, :work, @phone_number)
      assert Repo.get_by(PhoneNumber, number: @phone_number)
    end

    test "creates an ignored phone number", %{user: u} do
      assert match? {:ok, _}, create_phone_number(u.id, :work, @phone_number, ignored?: true)
    end

    test "creates an unsafe phone number", %{user: u} do
      assert match? {:ok, _}, create_phone_number(u.id, :work, @phone_number, safe?: true)
    end

    test "errors if type is invalid", %{user: u} do
      assert create_phone_number(u.id, :invalid, @phone_number) == {:error, :unknown_type}
    end

    test "errors if user does not exist" do
      assert create_phone_number(-1, :work, @phone_number) == {:error, :no_user}
    end

    test "errors if phone number is invalid", %{user: u} do
      assert create_phone_number(u.id, :work, "test") == {:error, :invalid}
    end
  end

  describe "update_phone_number/3" do
    test "updates a phone number", %{phone_number: pn} do
      assert match? {:ok, _}, update_phone_number(pn.id, :work, @changed_phone_number)
      assert Repo.get_by(PhoneNumber, id: pn.id).number == @changed_phone_number
    end

    test "errors if type is invalid", %{phone_number: pn} do
      assert update_phone_number(pn.id, :invalid, @changed_phone_number) == {:error, :unknown_type}
    end

    test "errors if phone number does not exist" do
      assert update_phone_number(-1, :work, @changed_phone_number) == {:error, :not_found}
    end

    test "errors if phone number is invalid", %{phone_number: pn} do
      assert update_phone_number(pn.id, :work, "test") == {:error, :invalid}
    end
  end

  describe "remove_phone_number/1" do
    test "deletes a phone number", %{phone_number: pn} do
      assert remove_phone_number(pn.id) == :ok
      refute Repo.get_by(PhoneNumber, id: pn.id)
    end

    test "errors if phone number does not exist" do
      assert remove_phone_number(-1) == {:error, :not_found}
    end
  end

  describe "make_primary/1" do
    test "makes a phone number primary", %{phone_number: pn} do
      assert match? {:ok, _}, make_primary(pn.id)
    end

    test "errors if phone number is marked ignored" do
      pn = Factory.insert(:phone_number, ignored?: true)

      assert make_primary(pn.id) == {:error, :ignored}
    end

    test "errors if phone number is marked unsafe" do
      pn = Factory.insert(:phone_number, safe?: false)

      assert make_primary(pn.id) == {:error, :unsafe}
    end

    test "errors if there is no such phone number" do
      assert make_primary(-1) == {:error, :not_found}
    end
  end

  describe "ignore_phone_number/1" do
    test "ignores a phone number" do
      pn = Factory.insert(:phone_number, ignored?: false)

      assert match? {:ok, _}, ignore_phone_number(pn.id)
    end

    test "does not error if phone number is already ignored" do
      pn = Factory.insert(:phone_number, ignored?: true)

      assert match? {:ok, _}, ignore_phone_number(pn.id)
      assert Repo.get_by(PhoneNumber, id: pn.id, ignored?: true)
    end

    test "errors if there is no such phone number" do
      assert ignore_phone_number(-1) == {:error, :not_found}
    end
  end

  describe "acknowledge_phone_number/1" do
    test "removes an ignore mark on a phone number" do
      pn = Factory.insert(:phone_number, ignored?: true)

      assert match? {:ok, _}, acknowledge_phone_number(pn.id)
      assert Repo.get_by(PhoneNumber, id: pn.id, ignored?: false)
    end

    test "does not error if phone number is not ignored yet" do
      pn = Factory.insert(:phone_number, ignored?: false)

      assert match? {:ok, _}, acknowledge_phone_number(pn.id)
      assert Repo.get_by(PhoneNumber, id: pn.id, ignored?: false)
    end

    test "errors if there is no such phone number" do
      assert acknowledge_phone_number(-1) == {:error, :not_found}
    end
  end

  describe "mark_phone_number_safe/1" do
    test "marks a phone number safe" do
      pn = Factory.insert(:phone_number, safe?: false)

      assert match? {:ok, _}, mark_phone_number_safe(pn.id)
      assert Repo.get_by(PhoneNumber, id: pn.id, safe?: true)
    end

    test "does not error if phone number is safe already" do
      pn = Factory.insert(:phone_number, safe?: true)

      assert match? {:ok, _}, mark_phone_number_safe(pn.id)
      assert Repo.get_by(PhoneNumber, id: pn.id, safe?: true)
    end

    test "errors if there is no such phone number" do
      assert mark_phone_number_safe(-1) == {:error, :not_found}
    end
  end

  describe "mark_phone_number_unsafe/1" do
    test "marks a phone number unsafe" do
      pn = Factory.insert(:phone_number, safe?: true)

      assert match? {:ok, _}, mark_phone_number_unsafe(pn.id)
      assert Repo.get_by(PhoneNumber, id: pn.id, safe?: false)
    end

    test "does not error if phone number is marked unsafe" do
      pn = Factory.insert(:phone_number, safe?: false)

      assert match? {:ok, _}, mark_phone_number_unsafe(pn.id)
      assert Repo.get_by(PhoneNumber, id: pn.id, safe?: false)
    end

    test "errors if there is no such phone number" do
      assert mark_phone_number_unsafe(-1) == {:error, :not_found}
    end
  end
end