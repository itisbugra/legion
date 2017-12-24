use Mix.Config

# Configure your database
config :legion, Legion.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "legion_dev",
  hostname: "localhost",
  pool_size: 10
