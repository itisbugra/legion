use Mix.Config

# Use canary configuration as baseline
import_config "canary.exs"

# Configure the database
config :legion, Legion.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "legion_dev",
  hostname: "localhost",
  pool_size: 10
