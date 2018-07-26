defmodule Legion.HTTP.FallbackController do
  use Legion.HTTP, :controller 

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(Legion.HTTP.Common.ChangesetView, "error.json", changeset: changeset)
  end
end