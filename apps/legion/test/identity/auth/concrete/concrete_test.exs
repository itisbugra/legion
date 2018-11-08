defmodule Legion.Identity.Auth.ConcreteTest do
  @moduledoc false
  use Legion.DataCase

  import Legion.Identity.Auth.Concrete
  import NaiveDateTime, only: [utc_now: 0, add: 3]

  alias Legion.Identity.Auth.Algorithm.Keccak
  alias Legion.Identity.Auth.Insecure.Pair

  @insecure_env Application.get_env(:legion, Legion.Identity.Auth.Insecure)
  @username_length Keyword.fetch!(@insecure_env, :username_length)
  @password_length Keyword.fetch!(@insecure_env, :password_length)

  @concrete_env Application.get_env(:legion, Legion.Identity.Auth.Concrete)
  @maximum_allowed_passphrases Keyword.fetch!(@concrete_env, :maximum_allowed_passphrases)
  @passphrase_lifetime Keyword.fetch!(@concrete_env, :passphrase_lifetime)

  describe "registers_internal_user/2" do
    setup do
      %{
        username: random_string(Enum.min(@username_length)),
        password: random_string(@password_length)
      }
    end

    test "registers a user", %{username: username, password: password} do
      {:ok, user_id, _inserted_at} = register_internal_user(username, password)

      assert is_integer(user_id)
    end

    test "does not register the user if username is already taken", %{
      username: username,
      password: password
    } do
      # save the user for once
      register_internal_user(username, password)

      assert match?({:error, _}, register_internal_user(username, password))
    end

    test "does not register the user if username is short", %{password: password} do
      username = random_string(Enum.min(@username_length) - 1)

      assert match?({:error, _}, register_internal_user(username, password))
    end

    test "does not register the user if username is long", %{password: password} do
      username = random_string(Enum.max(@username_length) + 1)

      assert match?({:error, _}, register_internal_user(username, password))
    end

    test "does not register the user if password is not in predetermined length", %{
      username: username
    } do
      password = random_string(@password_length + 1)

      assert match?({:error, _}, register_internal_user(username, password))
    end
  end

  describe "generate_passphrase/4" do
    setup do
      user = insert(:user)
      password = random_string(@password_length)
      password_hash = Keccak.hash(password)
      password_digest = Pair.hashpwsalt(password_hash)

      %{
        user: insert(:user),
        password: password,
        password_hash: password_hash,
        password_digest: password_digest,
        pair: insert(:pair, user: user, password_digest: password_digest),
        ip_addr: {1, 1, 1, 1}
      }
    end

    test "matching username/password combination returns passkey", %{
      password_hash: password_hash,
      pair: pair,
      ip_addr: ip_addr
    } do
      assert match?(
               {:ok, :require, _},
               generate_passphrase(pair.username, password_hash, ip_addr)
             )
    end

    test "if user does not exist says no user", %{password_hash: password_hash, ip_addr: ip_addr} do
      assert {:error, :no_user_verify} ==
               generate_passphrase("_failing_some_username", password_hash, ip_addr)
    end

    test "returns wrong password if hash is not verified", %{
      pair: pair,
      password_hash: password_hash,
      ip_addr: ip_addr
    } do
      assert {:error, :wrong_password_hash} ==
               generate_passphrase(
                 pair.username,
                 random_string(String.length(password_hash)),
                 ip_addr
               )
    end

    test "errors if user already has maximum amount of passphrases exceed", %{
      pair: pair,
      password_hash: password_hash,
      ip_addr: ip_addr
    } do
      _passphrases = insert_list(@maximum_allowed_passphrases, :passphrase, user: pair.user)

      assert {:error, :maximum_passphrases_exceeded} ==
               generate_passphrase(pair.username, password_hash, ip_addr)
    end

    @tag :regression
    test "outdated passphrases do not count in allowance limit", %{
      pair: pair,
      password_hash: password_hash,
      ip_addr: ip_addr
    } do
      invalidation_moment = add(utc_now(), -(@passphrase_lifetime + 1), :second)

      _passphrases =
        insert_list(@maximum_allowed_passphrases, :passphrase,
          user: pair.user,
          inserted_at: invalidation_moment
        )

      assert match?(
               {:ok, :require, _},
               generate_passphrase(pair.username, password_hash, ip_addr)
             )
    end

    @tag :regression
    test "invalidated passphrases do not count in allowance limit", %{
      pair: pair,
      password_hash: password_hash,
      ip_addr: ip_addr
    } do
      source = insert(:passphrase, user: pair.user)

      @maximum_allowed_passphrases
      |> insert_list(:passphrase, user: pair.user)
      |> Enum.each(fn target ->
        insert(:passphrase_invalidation, source_passphrase: source, target_passphrase: target)
      end)

      assert match?(
               {:ok, :require, _},
               generate_passphrase(pair.username, password_hash, ip_addr)
             )
    end
  end
end
