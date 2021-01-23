defmodule Legion.Identity.Telephony.PhoneNumber.FiniteStateMachineTest do
  @moduledoc false
  use Legion.DataCase

  import Legion.Identity.Telephony.Stub
  import Legion.Identity.Telephony.PhoneNumber.FiniteStateMachine

  alias Legion.Identity.Telephony.PhoneNumber

  @phone_number "+966558611111"
  @changed_phone_number "+966558611112"

  setup do
    scaffold_stubs()
  end

  describe "safe_until/1" do
    test "shows the timestamp the entry is safe until", %{safe: pn} do
      result = safe_until(pn.id)

      refute result == :unsafe

      assert DateTime.to_iso8601(result) =~
               ~r/[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{6}Z/
    end

    test "returns unsafe is number is not safe", %{unsafe: pn} do
      assert safe_until(pn.id) == :unsafe
    end

    test "raises if phone number does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        safe_until(-1)
      end
    end
  end

  describe "safe?/1" do
    test "returns true if number is safe", %{safe: pn} do
      assert safe?(pn.id)
    end

    test "returns false if number is not safe", %{unsafe: pn} do
      refute safe?(pn.id)
    end

    test "raises if phone number does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        safe?(-1)
      end
    end
  end

  describe "ignored?/1" do
    test "returns true if number is ignored", %{safe_but_ignored: pn} do
      assert ignored?(pn.id)
    end

    test "returns false if number is not ignored", %{safe: pn} do
      refute ignored?(pn.id)
    end

    test "raises if phone number does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        ignored?(-1)
      end
    end
  end

  describe "primary?/1" do
    test "returns true if number is prioritized", %{safe_and_prioritized: pn} do
      assert primary?(pn.id)
    end

    test "returns false if number is not prioritized", %{safe_and_overprioritized: pn} do
      refute primary?(pn.id)
    end

    test "raises if phone number does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        primary?(-1)
      end
    end

    @tag :regression
    # regression: GitLab issue, #20
    test "returns true if number is prioritized by user himself" do
      user = Factory.insert(:user)
      passphrase = Factory.insert(:passphrase, user: user)
      phone_number = Factory.insert(:phone_number, user: user)

      _prioritization_trait =
        Factory.insert(:phone_number_prioritization_trait,
          phone_number: phone_number,
          authority: passphrase
        )

      assert primary?(phone_number.id)
    end
  end

  describe "create_phone_number/4" do
    test "creates a phone number", %{owner: u} do
      assert match?({:ok, _}, create_phone_number(u.id, :work, @phone_number))
      assert Repo.get_by(PhoneNumber, number: @phone_number)
    end

    test "errors if type is invalid", %{owner: u} do
      assert create_phone_number(u.id, :invalid, @phone_number) == {:error, :unknown_type}
    end

    test "errors if user does not exist" do
      assert create_phone_number(-1, :work, @phone_number) == {:error, :no_user}
    end

    test "errors if phone number is invalid", %{owner: u} do
      assert create_phone_number(u.id, :work, "test") == {:error, :invalid}
    end
  end

  describe "update_phone_number/3" do
    test "updates a phone number", %{safe: pn} do
      assert match?({:ok, _}, update_phone_number(pn.id, :work, @changed_phone_number))
      assert Repo.get_by(PhoneNumber, id: pn.id).number == @changed_phone_number
    end

    test "errors if type is invalid", %{safe: pn} do
      assert update_phone_number(pn.id, :invalid, @changed_phone_number) ==
               {:error, :unknown_type}
    end

    test "errors if phone number does not exist" do
      assert update_phone_number(-1, :work, @changed_phone_number) == {:error, :not_found}
    end

    test "errors if phone number is invalid", %{safe: pn} do
      assert update_phone_number(pn.id, :work, "test") == {:error, :invalid}
    end
  end

  describe "remove_phone_number/1" do
    test "deletes a phone number", %{safe: pn} do
      assert remove_phone_number(pn.id) == :ok
      refute Repo.get_by(PhoneNumber, id: pn.id)
    end

    test "errors if phone number does not exist" do
      assert remove_phone_number(-1) == {:error, :not_found}
    end
  end

  describe "make_primary/2" do
    test "prioritizes a phone number", %{owner_passphrase: pp, safe: pn} do
      assert match?({:ok, _}, make_primary(pp.id, pn.id))
    end

    test "is a noop if phone number is already primary", %{
      owner_passphrase: pp,
      safe_and_prioritized: pn
    } do
      assert make_primary(pp.id, pn.id) == {:ok, :noop}
    end

    test "errors if phone number is marked ignored", %{owner_passphrase: pp, safe_but_ignored: pn} do
      assert make_primary(pp.id, pn.id) == {:error, :phone_number, :ignored}
    end

    test "errors if phone number is marked unsafe", %{owner_passphrase: pp, unsafe: pn} do
      assert make_primary(pp.id, pn.id) == {:error, :phone_number, :unsafe}
    end

    test "errors if there is no such phone number", %{owner_passphrase: pp} do
      assert make_primary(pp.id, -1) == {:error, :phone_number, :not_found}
    end

    test "errors if there is no such passphrase", %{safe: pn} do
      assert make_primary(-1, pn.id) == {:error, :passphrase, :not_found}
    end
  end

  describe "ignore_phone_number/2" do
    test "ignores a phone number", %{owner_passphrase: pp, safe: pn} do
      assert match?({:ok, _}, ignore_phone_number(pp.id, pn.id))
    end

    test "does not error if phone number is already ignored", %{
      owner_passphrase: pp,
      safe_but_ignored: pn
    } do
      assert match?({:ok, _}, ignore_phone_number(pp.id, pn.id))
    end

    test "errors if phone number is primary", %{owner_passphrase: pp, safe_and_prioritized: pn} do
      assert ignore_phone_number(pp.id, pn.id) == {:error, :phone_number, :primary}
    end

    test "errors if phone_number is not safe", %{owner_passphrase: pp, unsafe: pn} do
      assert ignore_phone_number(pp.id, pn.id) == {:error, :phone_number, :unsafe}
    end

    test "errors if there is no such phone number", %{owner_passphrase: pp} do
      assert ignore_phone_number(pp.id, -1) == {:error, :phone_number, :not_found}
    end

    test "errors if there is no such passphrase", %{safe: pn} do
      assert ignore_phone_number(-1, pn.id) == {:error, :passphrase, :not_found}
    end
  end

  describe "acknowledge_phone_number/1" do
    test "removes an ignore mark on a phone number", %{safe_but_ignored: pn} do
      assert match?({:ok, _}, acknowledge_phone_number(pn.id))
    end

    test "does not error if phone number is not ignored yet", %{safe: pn} do
      assert match?({:ok, _}, acknowledge_phone_number(pn.id))
    end

    test "errors if there is no such phone number" do
      assert acknowledge_phone_number(-1) == {:error, :not_found}
    end
  end

  describe "mark_phone_number_safe/2" do
    test "marks a phone number safe", %{owner_passphrase: pp, unsafe: pn} do
      assert match?({:ok, _}, mark_phone_number_safe(pp.id, pn.id))
    end

    test "does not error if phone number is safe already", %{owner_passphrase: pp, safe: pn} do
      assert match?({:ok, _}, mark_phone_number_safe(pp.id, pn.id))
    end

    test "errors if there is no such phone number", %{owner_passphrase: pp} do
      assert mark_phone_number_safe(pp.id, -1) == {:error, :phone_number, :not_found}
    end

    test "errors if there is no such passphrase", %{unsafe: pn} do
      assert mark_phone_number_safe(-1, pn.id) == {:error, :passphrase, :not_found}
    end
  end

  describe "mark_phone_number_unsafe/2" do
    test "marks a phone number unsafe", %{owner_passphrase: pp, safe: pn} do
      assert match?({:ok, _}, mark_phone_number_unsafe(pp.id, pn.id))
    end

    test "does not error if phone number is marked unsafe", %{owner_passphrase: pp, unsafe: pn} do
      assert match?({:ok, _}, mark_phone_number_unsafe(pp.id, pn.id))
    end

    test "errors if there is no such phone number", %{owner_passphrase: pp} do
      assert mark_phone_number_unsafe(pp.id, -1) == {:error, :phone_number, :not_found}
    end

    test "errors if there is no such passphrase", %{safe: pn} do
      assert mark_phone_number_unsafe(-1, pn.id) == {:error, :passphrase, :not_found}
    end
  end
end
