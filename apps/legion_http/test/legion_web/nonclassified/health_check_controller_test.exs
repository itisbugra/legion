defmodule Legion.HTTP.Nonclassified.HealthCheckControllerTest do
  @moduledoc false
  use Legion.HTTP.ConnCase

  test "health check returns empty content", %{conn: conn} do
    result =
      conn
      |> head("/api")
      |> text_response(204)

    assert result == ""
  end
end
