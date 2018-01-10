defmodule Legion.Identity.Auth.Concrete.TokenTest do
  @moduledoc false
  use Legion.DataCase

  import Legion.Identity.Auth.Concrete.Token
  import NaiveDateTime, only: [utc_now: 0, add: 2]

  alias Legion.Identity.Information.Registration
  alias Legion.Identity.Auth.Concrete.Passphrase
  alias Legion.Identity.Auth.Concrete.Passphrase.Invalidation

  @passkey_digest "$argon2i$v=19$m=65536,t=6,p=1$SoJWXxCYs6cTOW4PEZqJ6w$WQhD2UBB9fp2eA5PA2UOzXa7djroksasNNGgB8m0Nko"
  @ipv4 %Postgrex.INET{address: {46, 196, 25, 86}}

  test "issues token with given user and passphrase" do
    user = %Registration{id: 1}
    passphrase = %Passphrase{user_id: 1,
                             passkey_digest: @passkey_digest,
                             ip_addr: @ipv4,
                             inserted_at: utc_now(),
                             invalidation: nil}

    result = issue_token(user, passphrase)

    str = elem(result, 1)

    assert elem(result, 0) == :ok
    assert str.header_value
    assert str.jwk
    assert str.jws
    assert str.expires_after
  end

  test "does not issue token if passphrase is invalid" do
    user = %Registration{id: 1}
    inv = %Invalidation{source_passphrase_id: 1, target_passphrase_id: 1}
    passphrase = %Passphrase{id: 1,
                             user_id: 1,
                             passkey_digest: @passkey_digest,
                             ip_addr: @ipv4,
                             inserted_at: utc_now(),
                             invalidation: inv}

    assert issue_token(user, passphrase) == {:error, :invalid}
  end

  test "does not issue token if passphrase is outdated" do
    env = Application.get_env(:legion, Legion.Identity.Auth.Concrete)
    offset = Keyword.fetch!(env, :passphrase_lifetime) + 200_000
    time = add(utc_now(), (-1) * offset)

    user = %Registration{id: 1}
    passphrase = 
      %Passphrase{id: 1,
                  user_id: 2,
                  passkey_digest: @passkey_digest,
                  inserted_at: time,
                  invalidation: nil}

    assert issue_token(user, passphrase) == {:error, :timed_out}
  end
end
