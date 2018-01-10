defmodule Legion.Identity.Auth.Concrete.PassphraseTest do
  @moduledoc false
  use Legion.DataCase

  import NaiveDateTime, only: [utc_now: 0, add: 2]

  alias Legion.Identity.Auth.Concrete.Passphrase
  alias Legion.Identity.Auth.Concrete.Passphrase.Invalidation
  alias Legion.Identity.Information.Registration

  @digest "$argon2i$v=19$m=65536,t=6,p=1$SoJWXxCYs6cTOW4PEZqJ6w$WQhD2UBB9fp2eA5PA2UOzXa7djroksasNNGgB8m0Nko"
  @ip_addr {176, 54, 71, 200}
  @valid_attrs %{user_id: 2,
                 passkey_digest: @digest,
                 ip_addr: %Postgrex.INET{address: @ip_addr}}

  test "changeset with valid attributes" do
    changeset = 
      Passphrase.changeset(%Passphrase{},
                           @valid_attrs)

    assert changeset.valid?
  end

  test "changeset without user identifier" do
    changeset =
      Passphrase.changeset(%Passphrase{},
                           %{passkey_digest: @digest,
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

  test "changeset without ip address" do
    changeset =
      Passphrase.changeset(%Passphrase{},
                           %{user_id: 2,
                             passkey_digest: @digest})

    refute changeset.valid?
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
    test "returns ok if passphrase is valid" do
    passphrase = 
      %Passphrase{user_id: 2,
                  passkey_digest: @digest,
                  inserted_at: utc_now(),
                  invalidation: nil}

    assert Passphrase.validate(passphrase) == :ok
  end

  test "returns error if passphrase is invalidated" do
    invalidation = 
      %Invalidation{source_passphrase_id: 1,
                    target_passphrase_id: 1}
    passphrase = 
      %Passphrase{id: 1,
                  user_id: 2,
                  passkey_digest: @digest,
                  inserted_at: utc_now(),
                  invalidation: invalidation}

    assert Passphrase.validate(passphrase) == {:error, :invalid}
  end

  test "returns error if passphrase is timed out" do
    env = Application.get_env(:legion, Legion.Identity.Auth.Concrete)
    offset = Keyword.fetch!(env, :passphrase_lifetime) + 200_000
    time = add(utc_now(), (-1) * offset)

    passphrase = 
      %Passphrase{id: 1,
                  user_id: 2,
                  passkey_digest: @digest,
                  inserted_at: time,
                  invalidation: nil}

    assert Passphrase.validate(passphrase) == {:error, :timed_out}
  end
  end
end
