defmodule Legion.HTTP.Common.FallbackController do
  @moduledoc """
  Handles fallback actions of controllers.
  """
  use Legion.HTTP, :controller 

  @doc """
  A fallback handler to handle Ecto errors encoded as changesets.
  """
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(Legion.HTTP.Common.ChangesetView, "error.json", changeset: changeset)
  end
end