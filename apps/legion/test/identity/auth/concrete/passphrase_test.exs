defmodule Legion.Identity.Auth.Concrete.PassphraseTest do
  @moduledoc false
  use Legion.DataCase

  import NaiveDateTime, only: [utc_now: 0, add: 2]
  import Legion.Identity.Auth.Concrete.Passkey

  alias Legion.Identity.Auth.Concrete.Passphrase
  alias Legion.Identity.Auth.Concrete.Passphrase.Invalidation
  alias Legion.Identity.Information.Registration

  @ip_addr {176, 54, 71, 200}

  setup do
    passkey = generate()

    %{passkey: passkey, 
      valid_attrs: %{user_id: 2,
                     passkey: passkey,
                     ip_addr: %Postgrex.INET{address: @ip_addr}}}
  end

  test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
    changeset = 
      Passphrase.changeset(%Passphrase{},
                           valid_attrs)

    assert changeset.valid?
  end

  test "changeset without user identifier", %{passkey: passkey} do
    changeset =
      Passphrase.changeset(%Passphrase{},
                           %{passkey: passkey,
                             ip_addr: %Postgrex.INET{address: @ip_addr}})

    refute changeset.valid?
  end

  test "changeset without passkey digest" do
    changeset =
      Passphrase.changeset(%Passphrase{},
                           %{user_id: 2,
                             ip_addr: %Postgrex.INET{address: @ip_addr}})

    refute changeset.valid?
  end

  test "changeset without ip address", %{passkey: passkey} do
    changeset =
      Passphrase.changeset(%Passphrase{},
                           %{user_id: 2,
                             passkey: passkey})

    refute changeset.valid?
  end

  test "changeset is invalid with default params either" do
    refute Passphrase.changeset(%Passphrase{}).valid?
  end

  describe "create_changeset/1" do
    test "returns changeset with raw passkey using primary key" do
      {passkey, changeset} = 
        Passphrase.create_changeset(2, @ip_addr)  # arbitrary integer as primary key

      assert passkey
      assert changeset.valid?
    end

    test "returns changeset with raw passkey using user struct" do
      user = %Registration{id: 2}

      {passkey, changeset} = 
        Passphrase.create_changeset(user, @ip_addr)  # arbitrary integer as primary key

      assert passkey
      assert changeset.valid?
    end
  end

  describe "validate/1" do
    test "returns ok if passphrase is valid", %{passkey: passkey} do
      passphrase = 
        %Passphrase{user_id: 2,
                    passkey: passkey,
                    inserted_at: utc_now(),
                    invalidation: nil}

      assert Passphrase.validate(passphrase) == :ok
    end

    test "returns error if passphrase is invalidated", %{passkey: passkey} do
      invalidation = 
        %Invalidation{source_passphrase_id: 1,
                      target_passphrase_id: 1}
      passphrase = 
        %Passphrase{id: 1,
                    user_id: 2,
                    passkey: passkey,
                    inserted_at: utc_now(),
                    invalidation: invalidation}

      assert Passphrase.validate(passphrase) == {:error, :invalid}
    end

    test "returns error if passphrase is timed out", %{passkey: passkey} do
      env = Application.get_env(:legion, Legion.Identity.Auth.Concrete)
      offset = Keyword.fetch!(env, :passphrase_lifetime) + 200_000
      time = add(utc_now(), (-1) * offset)

      passphrase = 
        %Passphrase{id: 1,
                    user_id: 2,
                    passkey: passkey,
                    inserted_at: time,
                    invalidation: nil}

      assert Passphrase.validate(passphrase) == {:error, :timed_out}
    end
  end

  describe "find_passphrase_matching/2" do
    setup do
      env = Application.get_env(:legion, Legion.Identity.Auth.Concrete)
      offset = Keyword.fetch!(env, :passphrase_lifetime) + 200_000
      time = add(utc_now(), (-1) * offset)

      user = Factory.insert(:user)
      passphrase = Factory.insert(:passphrase, user: user)
      timed_out = Factory.insert(:passphrase, user: user, inserted_at: time)
      invalidated = Factory.insert(:passphrase, user: user)
      _invalidation = Factory.insert(:passphrase_invalidation, source_passphrase: passphrase, target_passphrase: invalidated)

      %{user: user, 
        passphrase: passphrase, 
        time_threshold: time,
        timed_out: timed_out,
        invalidated: invalidated}
    end

    test "finds an existing passhrase", %{user: u, passphrase: p} do
      assert Passphrase.find_passphrase_matching(u.id, p.passkey) == {:ok, p.id}
    end

    test "returns error if no passphrase exists with given passkey", %{user: u} do
      assert Passphrase.find_passphrase_matching(u.id, "(null)") == {:error, :not_found}
    end

    test "returns error if passphrase is passed out", %{user: u, timed_out: tp} do
      assert Passphrase.find_passphrase_matching(u.id, tp.passkey) == {:error, :timed_out}
    end

    test "returns error if passphrase is invalidated", %{user: u, invalidated: ip} do
      assert Passphrase.find_passphrase_matching(u.id, ip.passkey) == {:error, :invalid}
    end
  end
end
