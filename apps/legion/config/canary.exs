use Mix.Config

six_months = 15_552_000
half_of_an_hour = 3_600
three_minutes = 180

config :ua_inspector,
  database_path: Path.join(Mix.Utils.mix_home, "ua_inspector")

config :freegeoip, 
  base_url: "http://localhost:8080"

# Access control basics
config :legion, Legion.Identity.Auth.AccessControl,
  permission_set_name_length: 4..28,
  permission_set_description_length: 8..80,
  maximum_granting_deferral: six_months,
  maximum_granting_lifetime: six_months,
  allow_infinite_lifetime: true

# Concrete authentication basics
config :legion, Legion.Identity.Auth.Concrete,
  passkey_scaling: 4,
  passphrase_lifetime: six_months,
  user_agent_length: 400

# JSON Object Signing and Encoding (JOSE) settings
config :legion, Legion.Identity.Auth.Concrete.JOSE,
  secret_key_base: "secret_key_base",
  issuer: "legion",
  lifetime: half_of_an_hour,
  sub: "access"

config :legion, Legion.Identity.Auth.Insecure,
  allowed_cleartext_safe_artifacts: [:username, :email],
  username_type: :alphanumeric,
  username_length: 6..20,
  username_requires_check: false,
  bypass_concrete_auth: true,
  password_digestion: :argon2,
  password_type: :unicode,
  password_length: 8..32,
  password_minimum_security_level: :all

config :legion, Legion.Identity.Auth.OTC,
  lifetime: three_minutes,
  type: :integer,
  length: 6,
  prefix: "",
  postfix: "",
  medium: Legion.Identity.Auth.OTC.Adapters.SMS

config :legion, Legion.Identity.Auth.Concrete.TFA,
  lifetime: three_minutes,
  allowed_attempts: 3

config :legion, Legion.Identity.Auth.Algorithm,
  keccak_variant: :sha3_512

config :legion, Legion.Messaging.Medium.APM,
  subject_length: 2..40,
  body_length: 5..255,
  is_enabled?: true

config :legion, Legion.Messaging.Medium.Push,
  subject_length: 2..40,
  body_length: 5..255,
  is_enabled?: true

config :legion, Legion.Messaging.Medium.Mailing,
  subject_length: 2..40,
  body_length: 5..255,
  is_enabled?: true

config :legion, Legion.Messaging.Medium.SMS,
  subject_length: 2..40,
  body_length: 5..255,
  is_enabled?: true

config :legion, Legion.Messaging.Medium.Platform,
  subject_length: 2..40,
  body_length: 5..255,
  is_enabled?: true

config :legion, Legion.Messaging.Templatization,
  template_name_length: 5..50

