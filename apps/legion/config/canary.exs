use Mix.Config

six_months = 15_552_000
half_of_an_hour = 3_600
three_minutes = 180

config :ua_inspector,
  database_path: Path.join(Mix.Utils.mix_home(), "ua_inspector")

# Please check configuration documentation for the meanings of the values.

config :legion, Legion.Identity.Auth.AccessControl,
  permission_set_name_length: 4..28,
  permission_set_description_length: 8..80,
  maximum_granting_deferral: six_months,
  maximum_granting_lifetime: six_months,
  allow_infinite_lifetime: true

config :legion, Legion.Identity.Auth.Concrete,
  passkey_scaling: 4,
  passphrase_lifetime: six_months,
  user_agent_length: 400,
  maximum_allowed_passphrases: 5,
  allow_local_addresses: true

config :legion, Legion.Identity.Auth.Concrete.JOSE,
  secret_key_base: "secret_key_base",
  issuer: "legion",
  lifetime: half_of_an_hour,
  extended_lifetime: half_of_an_hour * 6,
  sub: "access"

config :legion, Legion.Identity.Auth.Insecure,
  username_length: 6..20,
  bypass_concrete_auth: true,
  password_digestion: :argon2,
  password_length: 128,
  dispute_wrong_password: false

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

config :legion, Legion.Identity.Auth.Algorithm, keccak_variant: :sha3_512

config :legion, Legion.Identity.Information.PersonalData,
  given_name_length: 1..80,
  middle_name_length: 1..80,
  family_name_length: 1..80,
  name_prefix_length: 1..80,
  name_postfix_length: 1..80,
  nickname_length: 1..80,
  phonetic_representation_length: 1..80

config :legion, Legion.Identity.Information.AddressBook,
  name_length: 1..24,
  description_length: 1..80,
  state_length: 1..24,
  city_length: 1..24,
  neighborhood_length: 1..24,
  zip_code_length: 1..24,
  listing_default_page_size: 5

config :legion, Legion.Identity.Telephony.PhoneNumber,
  initial_safe_duration: six_months,
  default_safe_duration: six_months,
  maximum_safe_duration: six_months * 2

config :legion, Legion.Messaging.Switching.Globals, history_buffer_length: 5

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
  body_length: 5..255,
  is_enabled?: true

config :legion, Legion.Messaging.Medium.Platform,
  subject_length: 2..40,
  body_length: 5..255,
  is_enabled?: true

config :legion, Legion.Messaging.Templatization, template_name_length: 5..50
