defmodule Legion.Identity.Auth.Concrete.TFAHandleTest do
  @moduledoc false
  use Legion.DataCase

  import Legion.Identity.Auth.TFA.OneTimeCode
  import NaiveDateTime, only: [utc_now: 0, add: 2]

  alias Legion.Identity.Auth.Concrete.TFAHandle

  @otc "L123456"
  @valid_attrs %{user_id: 1,
                 otc: @otc,
                 passphrase_id: 1}
  @env Application.get_env(:legion, Legion.Identity.Auth.Concrete.TFA)
  @lifetime Keyword.fetch!(@env, :lifetime)

  test "changeset with valid attributes" do
    changeset =
      TFAHandle.changeset(%TFAHandle{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset without user identifier" do
    changeset =
      TFAHandle.changeset(%TFAHandle{}, %{otc: @otc, passphrase_id: 1})

    refute changeset.valid?
  end

  test "changeset without otc" do
    changeset =
      TFAHandle.changeset(%TFAHandle{}, %{user_id: 1, passphrase_id: 1})

    refute changeset.valid?
  end

  test "changeset without passphrase identifier" do
    changeset =
      TFAHandle.changeset(%TFAHandle{}, %{user_id: 1, otc: @otc})

    assert changeset.valid?
  end

  test "hashes otc upon change" do
    changeset =
      TFAHandle.changeset(%TFAHandle{}, @valid_attrs)

    assert changeset.changes.otc_digest
    assert changeset.changes.otc_digest != @valid_attrs.otc
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
      _handle = insert(:tfa_handle, user: user)

      result = TFAHandle.challenge_handle(user, "L123456")

      assert elem(result, 0) == :ok
    end

    test "refuses challenge if given otc is not true" do
      user = insert(:user)
      _handle = insert(:tfa_handle, user: user)

      assert TFAHandle.challenge_handle(user, "L111111") == {:error, :bad_code}
    end

    test "refuses challenge if given otc is blank" do
      user = insert(:user)
      _handle = insert(:tfa_handle, user: user)

      assert TFAHandle.challenge_handle(user, "") == {:error, :bad_code}
    end

    test "refuses challenge if given otc is invalid" do
      user = insert(:user)
      _handle = insert(:tfa_handle, user: user)

      assert TFAHandle.challenge_handle(user, "π123456") == {:error, :bad_code}
    end

    test "refuses challenge if handle is not found" do
      user = insert(:user)

      assert TFAHandle.challenge_handle(user, "L123456")
    end

    test "refuses challenge if handle is outdated" do
      user = insert(:user)
      _outdated_handle = insert(:tfa_handle, user: user, inserted_at: add(utc_now(), @lifetime + 1))

      assert TFAHandle.challenge_handle(user, "L123456") == {:error, :not_found}
    end

    test "refuses challenge if handle is already satisfied" do
      user = insert(:user)
      passphrase = insert(:passphrase)
      _handle = insert(:tfa_handle, user: user, passphrase: passphrase)

      assert TFAHandle.challenge_handle(user, "L123456") == {:error, :not_found}
    end

    test "refuses challenge if handle is overridden" do
      user = insert(:user)
      _outdated_handle = insert(:tfa_handle, user: user)
      _new_handle = insert(:tfa_handle, user: user, otc_digest: hashpwsalt("L654321"))

      assert TFAHandle.challenge_handle(user, "L123456") == {:error, :bad_code}
    end 
  end
end
