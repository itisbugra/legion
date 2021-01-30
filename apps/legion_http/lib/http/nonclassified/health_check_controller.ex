defmodule Legion.HTTP.Nonclassified.HealthCheckController do
  @moduledoc """
  Provides a health check route.
  """
  use Legion.HTTP, :controller

  action_fallback Legion.HTTP.Common.FallbackController

  def peek(conn, _), do: conn |> put_status(:no_content) |> text("")
end
