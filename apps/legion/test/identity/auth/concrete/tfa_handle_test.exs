defmodule Legion.Identity.Auth.Concrete.TFAHandleTest do
  @moduledoc false
  use Legion.DataCase

  import Legion.Identity.Auth.TFA.OneTimeCode
  import NaiveDateTime, only: [utc_now: 0, add: 2]

  alias Legion.Identity.Auth.Concrete.TFAHandle

  @env Application.get_env(:legion, Legion.Identity.Auth.Concrete.TFA)
  @lifetime Keyword.fetch!(@env, :lifetime)
  @allowed_attempts Keyword.fetch!(@env, :allowed_attempts)
  @blank_otc ""
  @invalid_otc "π123456"

  setup do
    %{otc: generate_otc(), valid_attrs: generate_valid_attrs()}
  end

  test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
    changeset =
      TFAHandle.changeset(%TFAHandle{}, valid_attrs)

    assert changeset.valid?
  end

  test "changeset without user identifier", %{otc: otc} do
    changeset =
      TFAHandle.changeset(%TFAHandle{}, %{otc: otc, passphrase_id: 1})

    refute changeset.valid?
  end

  test "changeset without otc" do
    changeset =
      TFAHandle.changeset(%TFAHandle{}, %{user_id: 1, passphrase_id: 1})

    refute changeset.valid?
  end

  test "changeset without passphrase identifier", %{otc: otc} do
    changeset =
      TFAHandle.changeset(%TFAHandle{}, %{user_id: 1, otc: otc})

    assert changeset.valid?
  end

  test "hashes otc upon change", %{valid_attrs: valid_attrs} do
    changeset =
      TFAHandle.changeset(%TFAHandle{}, valid_attrs)

    assert changeset.changes.otc_digest
    assert changeset.changes.otc_digest != valid_attrs.otc
  end

  test "changeset is invalid with default params" do
    refute TFAHandle.changeset(%TFAHandle{}).valid?
  end

  describe "create_handle/1" do
    test "creates a handle with given user" do
      user = insert(:user)

      result =
        user
        |> TFAHandle.create_handle()
        |> Kernel.elem(0)

      assert result == :ok
    end

    test "does not create handle and returns error if user does not exist" do
      assert TFAHandle.create_handle(-1) == {:error, :not_found}
    end
  end

  describe "challenge_handle/2" do
    test "challenges a handle with given user identifier and otc" do
      user = insert(:user)
      handle = insert(:tfa_handle, user: user)

      result = TFAHandle.challenge_handle(user, handle.otc)

      assert elem(result, 0) == :ok
    end

    test "refuses challenge if given otc is not true", %{otc: otc} do
      user = insert(:user)
      _handle = insert(:tfa_handle, user: user)

      assert TFAHandle.challenge_handle(user, otc) == {:error, :no_match}
    end

    test "refuses challenge if given otc is blank" do
      user = insert(:user)
      _handle = insert(:tfa_handle, user: user)

      assert TFAHandle.challenge_handle(user, @blank_otc) == {:error, :bad_code}
    end

    test "refuses challenge if given otc is invalid" do
      user = insert(:user)
      handle = insert(:tfa_handle, user: user)

      assert TFAHandle.challenge_handle(user, @invalid_otc) == {:error, :no_match}
      assert Repo.get!(TFAHandle, handle.id).attempts == 1
    end

    test "refuses challenge if handle is not found", %{otc: otc} do
      user = insert(:user)

      assert TFAHandle.challenge_handle(user, otc)
    end

    test "refuses challenge if handle is outdated" do
      user = insert(:user)
      outdated_handle = insert(:tfa_handle, user: user, inserted_at: add(utc_now(), (-1) * (@lifetime)))

      assert TFAHandle.challenge_handle(user, outdated_handle.otc) == {:error, :not_found}
    end

    test "refuses challenge if handle is already satisfied" do
      user = insert(:user)
      passphrase = insert(:passphrase)
      handle = insert(:tfa_handle, user: user, passphrase: passphrase)

      assert TFAHandle.challenge_handle(user, handle.otc) == {:error, :not_found}
    end

    test "refuses challenge if handle is overridden" do
      user = insert(:user)
      outdated_handle = insert(:tfa_handle, user: user)
      new_handle = insert(:tfa_handle, user: user)

      assert TFAHandle.challenge_handle(user, outdated_handle.otc) == {:error, :no_match}
      assert Kernel.elem(TFAHandle.challenge_handle(user, new_handle.otc), 0) == :ok
    end

    test "refuses challenge if handle is attempted more than allowed" do
      user = insert(:user)
      handle = insert(:tfa_handle, user: user, attempts: @allowed_attempts)

      assert TFAHandle.challenge_handle(user, handle.otc) == {:error, :not_found}
    end
  end

  def generate_otc(), do: generate()
  def generate_valid_attrs(),
      do: %{user_id: 1,
            otc: generate_otc(),
            passphrase_id: 1}
end
