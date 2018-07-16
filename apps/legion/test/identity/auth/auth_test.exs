defmodule Legion.Identity.AuthTest do
  @moduledoc false
  use Legion.DataCase

  import Legion.Identity.Auth

  alias Legion.Identity.Auth.Algorithm.Keccak
  alias Legion.Identity.Auth.Insecure.Pair

  @env Application.get_env(:legion, Legion.Identity.Auth.Insecure)
  @username_length Keyword.fetch!(@env, :username_length)
  @password_length Keyword.fetch!(@env, :password_length)

  describe "registers_internal_user" do
    setup do
      %{username: random_string(Enum.min(@username_length)), 
        password: random_string(@password_length)}
    end

    test "registers a user", %{username: username, password: password} do
      {:ok, user_id, _inserted_at} = register_internal_user username, password

      assert is_integer(user_id)
    end

    test "does not register the user if username is already taken", %{username: username, password: password} do
      register_internal_user username, password     # save the user for once

      assert register_internal_user(username, password) |> elem(0) == :error
    end

    test "does not register the user if username is short", %{password: password} do
      username = random_string(Enum.min(@username_length) - 1)

      assert register_internal_user(username, password) |> elem(0) == :error
    end

    test "does not register the user if username is long", %{password: password} do
      username = random_string(Enum.max(@username_length) + 1)

      assert register_internal_user(username, password)  |> elem(0) == :error
    end

    test "does not register the user if password is not in predetermined length", %{username: username} do
      password = random_string(@password_length + 1)

      assert register_internal_user(username, password) |> elem(0) == :error
    end
  end

  describe "generate_passphrase" do
    setup do
      user = insert(:user)
      password = random_string(@password_length)
      password_hash = Keccak.hash(password)
      password_digest = Pair.hashpwsalt(password_hash)

      %{user: insert(:user),
        password: password,
        password_hash: password_hash,
        password_digest: password_digest,
        pair: insert(:pair, user: user, password_digest: password_digest),
        ip_addr: {1, 1, 1, 1}}
    end

    # test "generates passphrase", %{password_hash: password_hash, pair: pair, ip_addr: ip_addr} do
    #   result = generate_passphrase(pair.username, password_hash, ip_addr)

    #   assert Kernel.elem(result, 0) == :ok
    # end
  end
end