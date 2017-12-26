use Mix.Config

six_months = 15_552_000

# Configure access control basics
config :legion, Legion.Identity.Auth.AccessControl,
  permission_set_name_length: 4..28,
  permission_set_description_length: 8..80,
  maximum_granting_deferral: six_months,
  maximum_granting_lifetime: six_months,
  allow_infinite_lifetime: true

