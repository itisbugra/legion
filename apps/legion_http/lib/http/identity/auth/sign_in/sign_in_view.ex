defmodule Legion.HTTP.Identity.Auth.SignInView do
  @moduledoc """
  Renders responses and errors for the sign in process.
  """
  use Legion.HTTP, :view

  @env Application.get_env(:legion, Legion.Identity.Auth.Insecure)
  @dispute_wrong_password Keyword.fetch!(@env, :dispute_wrong_password)

  def render("error.json", %{error: :no_user_verify = error}) do
    error_map(
      error,
      "The challenge could not be completed with given credentials."
    )
  end

  def render("error.json", %{error: :unsupported_scheme = error}) do
    error_map(
      error,
      "The authentication scheme is currently unsupported."
    )
  end

  if @dispute_wrong_password do
    def render("error.json", %{error: :wrong_password = _error}) do
      error_map(
        :no_user_verify,
        "The challenge could not be completed with given credentials."
      )
    end
  else
    def render("error.json", %{error: :wrong_password = error}) do
      error_map(
        error,
        "The given credentials does not match with the user."
      )
    end
  end

  defp error_map(error, reason) do
    %{
      error: error,
      user_info: %{
        reason: reason
      }
    }
  end
end
