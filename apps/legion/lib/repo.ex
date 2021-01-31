defmodule Legion.Repo do
  @doc """
  Provides an `Ecto.Repo` for database connections.
  """
  use Ecto.Repo,
    otp_app: :legion,
    adapter: Ecto.Adapters.Postgres

  @dialyzer {:nowarn_function, rollback: 1}

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end
