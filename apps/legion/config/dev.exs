use Mix.Config

# Use canary configuration as baseline
import_config "canary.exs"

# Configure the database
config :legion, Legion.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "legion_dev",
  hostname: "postgres",
  pool_size: 10

# fiorix/freegeoip container in Docker to IP Reverse Geocoding
config :freegeoip,
  base_url: "http://fiorix-freegeoip:8080"
