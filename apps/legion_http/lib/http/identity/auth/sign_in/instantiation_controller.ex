defmodule Legion.HTTP.Identity.Auth.SignIn.InstantiationController do
  @moduledoc """
  Starts the authentication process of a user with an HTTP interface.
  """
  use Legion.HTTP, :controller

  import Legion.Identity.Auth, only: [generate_passphrase: 4]

  action_fallback(Legion.HTTP.Common.FallbackController)

  plug(:put_view, Legion.HTTP.Identity.Auth.SignInView)

  def create(conn, %{
        "username" => username,
        "password_hash" => password_hash,
        "one_shot" => one_shot
      }) do
    ip_addr = conn.remote_ip

    case generate_passphrase(username, password_hash, ip_addr, one_shot: one_shot) do
      {:ok, _, passkey} ->
        conn
        |> send_resp(201, passkey)

      {:error, :no_user_verify} ->
        conn
        |> put_status(:not_found)
        |> render("error.json", error: :no_user_verify)

      {:error, error} ->
        conn
        |> put_status(:bad_request)
        |> render("error.json", error: error)
    end
  end

  def create(conn, %{"username" => username, "password_hash" => password_hash}) do
    create(conn, %{"username" => username, "password_hash" => password_hash, "one_shot" => false})
  end
end
