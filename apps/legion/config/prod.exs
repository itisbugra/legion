use Mix.Config

# Use canary configuration as baseline
import_config "canary.exs"

# Configure the database
config :legion, Legion.Repo,
  username: System.get_env("POSTGRES_USERNAME", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  database: System.get_env("POSTGRES_DATABASE", "legion"),
  hostname: System.get_env("POSTGRES_HOSTNAME", "postgres"),
  port: System.get_env("POSTGRES_PORT", "5432") |> Integer.parse() |> elem(0),
  pool_size: 20

# fiorix/freegeoip container in Docker to IP Reverse Geocoding
config :freegeoip,
  base_url: "https://freegeoip.acme.services.thenopebox.com"
