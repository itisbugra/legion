defmodule Legion.HTTP.Identity.Auth.SignUp.RegistrationView do
  @moduledoc """
  Renders a map with given registration info.
  """
  use Legion.HTTP, :view

  def render("success.json", params) do
    %{registration_info: render_one(params, __MODULE__, "registration_info.json")}
  end

  def render("registration_info.json", %{registration: registration}) do
    %{username: registration.username,
      user_id: registration.user_id,
      timestamp: put_date(registration.inserted_at)}
  end
end
