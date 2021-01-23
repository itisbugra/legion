defmodule Legion.HTTP.Identity.Auth.SignUp.RegistrationController do
  @moduledoc """
  Registers users from internal API or external services.
  """
  use Legion.HTTP, :controller

  import Legion.Identity.Auth

  action_fallback Legion.HTTP.Common.FallbackController

  def create(conn, %{"username" => username, "password_hash" => password_hash}) do
    with {:ok, user_id, inserted_at} <- register_internal_user(username, password_hash) do
      conn
      |> put_status(:created)
      |> render("success.json", username: username, user_id: user_id, inserted_at: inserted_at)
    end
  end
end
