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

# If running on GitHub Actions, configure the database accordingly
if System.get_env("GITHUB_ACTIONS") do
  config :legion, Legion.Repo,
    adapter: Ecto.Adapters.Postgres,
    username: "postgres",
    password: "postgres",
    database: "legion_test",
    hostname: "postgres",
    pool: Ecto.Adapters.SQL.Sandbox
end

config :argon2_elixir,
  t_cost: 2,
  m_cost: 12

# fiorix/freegeoip container in Docker to IP Reverse Geocoding
config :freegeoip,
  base_url: "https://freegeoip.acme.services.thenopebox.com"

config :logger,
  level: :warn
