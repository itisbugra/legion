use Mix.Config

# Use canary configuration as baseline
import_config "canary.exs"

# Configure your database
config :legion, Legion.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "legion_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
