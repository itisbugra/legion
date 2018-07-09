defmodule Legion.Identity.AuthTest do
  @moduledoc false
  use Legion.DataCase

  import Legion.Identity.Auth

  @env Application.get_env(:legion, Legion.Identity.Auth.Insecure)
  @username_length Keyword.fetch!(@env, :username_length)
  @password_length Keyword.fetch!(@env, :password_length)

  describe "registers_internal_user" do
    setup do
      %{username: random_string(10), 
        password: random_string(12)}
    end

    test "registers a user", %{username: username, password: password} do
      {:ok, user_id} = register_internal_user username, password

      assert is_integer(user_id)
    end

    test "does not register the user if username is already taken", %{username: username, password: password} do
      register_internal_user username, password     # save the user for once

      assert register_internal_user(username, password) == {:error, :username}
    end

    test "does not register the user if username is short", %{password: password} do
      username = random_string(Enum.min(@username_length) - 1)

      assert register_internal_user(username, password) == {:error, :username}
    end

    test "does not register the user if username is long", %{password: password} do
      username = random_string(Enum.max(@username_length) + 1)

      assert register_internal_user(username, password) == {:error, :username}
    end

    test "does not register the user if password is short", %{username: username} do
      password = random_string(Enum.min(@password_length) - 1)

      assert register_internal_user(username, password) == {:error, :password}
    end

    test "does not register the user if password is long", %{username: username} do
      password = random_string(Enum.max(@password_length) + 1)

      assert register_internal_user(username, password) == {:error, :password}
    end
  end
end