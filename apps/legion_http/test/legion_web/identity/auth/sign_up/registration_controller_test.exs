defmodule Legion.HTTP.Identity.Auth.SignUp.RegistrationControllerTest do
  @moduledoc false
  use Legion.HTTP.ConnCase

  alias Legion.Identity.Auth.Algorithm.Keccak

  @insecure_env Application.get_env(:legion, Legion.Identity.Auth.Insecure)
  @username_length Keyword.fetch!(@insecure_env, :username_length)
  @password_length Keyword.fetch!(@insecure_env, :password_length)

  setup %{conn: conn} do
    username = random_string(Enum.min(@username_length))
    password = random_string(@password_length)
    password_hash = Keccak.hash(password)

    %{conn: conn,
      username: username,
      password: password,
      password_hash: password_hash}
  end

  test "registers a user with given username and password", %{conn: conn, username: username, password_hash: password_hash} do
    params =
      %{username: username,
        password_hash: password_hash}

    conn = post conn, registration_path(conn, :create), params
    result = json_response(conn, 201)["registration_info"]

    assert result["username"] == username
    assert result["user_id"]
    assert result["timestamp"]
  end

  test "should not contain a sensitive field", %{conn: conn, username: username, password_hash: password_hash} do
    params =
      %{username: username,
        password_hash: password_hash}

    conn = post conn, registration_path(conn, :create), params
    result = json_response(conn, 201)["registration_info"]

    refute result["password"]
    refute result["password_hash"]
    refute result["password_digest"]
  end
end