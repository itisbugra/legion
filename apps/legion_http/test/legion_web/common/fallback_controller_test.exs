defmodule Legion.HTTP.Common.FallbackControllerTest do
  @moduledoc false
  use Legion.HTTP.ConnCase

  import Ecto.Changeset, only: [change: 2, add_error: 3]

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.HTTP.Common.FallbackController

  test "delegates the errored changeset to the view", %{conn: conn} do
    changeset = 
      %User{id: 2, has_gps_telemetry_consent?: true}
      |> change(%{has_gps_telemetry_consent?: false})
      |> add_error(:has_gps_telemetry_consent?, "this should be false")

    conn = FallbackController.call(conn, {:error, changeset})

    assert conn.status == 422
  end
end