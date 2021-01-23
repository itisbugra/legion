defmodule Legion.HTTP.Identity.Auth.SignIn.InstantiationControllerTest do
  @moduledoc false
  use Legion.HTTP.ConnCase

  @insecure_env Application.get_env(:legion, Legion.Identity.Auth.Insecure)
  @username_length Keyword.fetch!(@insecure_env, :username_length)

  # setup, %{conn: conn} do
  #   username = random_string(Enum.min(@username_length))
  #   password_hash = 

  #   %{conn: conn,
  #     username: username,
  #     password_hash: random_string(128)}
  # end

  # test "registers a user with given username and password", %{conn: conn, username: username, password_hash: password_hash} do
  #   params = 
  #     %{username: username,
  #       password_hash: password_hash}

  #   conn = post conn, instantiation_path(conn, :create), params

  #   resp = json_response(conn, 201)

  #   assert resp["user_info"]["reason"]
  # end
end
