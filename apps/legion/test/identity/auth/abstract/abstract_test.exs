defmodule Legion.Identity.Auth.AbstractTest do
  @moduledoc false
  use Legion.DataCase

  import NaiveDateTime, only: [add: 2, utc_now: 0]
  import Legion.Identity.Auth.Abstract

  alias Legion.Identity.Auth.Concrete.Activity

  @ip_addr {45, 42, 45, 42}
  @ua "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1.2 Safari/605.1.15"
  @coordinate %Postgrex.Point{x: 5, y: 4}

  describe "authenticate/5" do
    setup do
      env = Application.get_env(:legion, Legion.Identity.Auth.Concrete)
      offset = Keyword.fetch!(env, :passphrase_lifetime) + 200_000
      time = add(utc_now(), -1 * offset)

      user = Factory.insert(:user)
      passphrase = Factory.insert(:passphrase, user: user)
      invalidated = Factory.insert(:passphrase, user: user)
      timed_out = Factory.insert(:passphrase, user: user, inserted_at: time)

      _invalidation =
        Factory.insert(:passphrase_invalidation,
          source_passphrase: passphrase,
          target_passphrase: invalidated
        )

      %{user: user, passphrase: passphrase, invalidated: invalidated, timed_out: timed_out}
    end

    test "generates a token for the user with valid passphrase", %{user: u, passphrase: p} do
      assert match?({:ok, _token}, authenticate(u, p.passkey, @ua, @ip_addr, @coordinate))
    end

    test "returns error if passphrase is invalid", %{user: u, invalidated: ip} do
      assert authenticate(u, ip.passkey, @ua, @ip_addr, @coordinate) == {:error, :invalid}
    end

    test "returns error if passphrase is passed out", %{user: u, timed_out: tp} do
      assert authenticate(u, tp.passkey, @ua, @ip_addr, @coordinate) == {:error, :timed_out}
    end

    test "returns error if ip address is invalid", %{user: u, passphrase: p} do
      ip_addr = {500, 500, 500, 500}

      assert authenticate(u, p.passkey, @ua, ip_addr, @coordinate) ==
               {:error, :incorrect_ip_range}
    end

    @tag :regression
    test "creates an activity", %{user: u, passphrase: p} do
      authenticate(u, p.passkey, @ua, @ip_addr, @coordinate)

      assert Repo.get_by(Activity, passphrase_id: p.id)
    end
  end
end
