# Configuration

Legion presents a completely opinionated authentication/authorization mechanism,
using best-practices as much as possible, however it also supports configuring
by supplying various configuration parameters in configuration files.

## Identity/Access Management (IAM)

### Access control

##### Path

`Legion.Identity.Auth.AccessControl`

##### Parameters

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | --- | ---
`permission_set_name_length` | [`Range.t()`] | - | Indicates the bounds of length of a permission set name. | `4..28`
`permission_set_description_length` | [`Range.t()`] | - | Indicates the bounds of length of a permission set description. | `8..80`
`maximum_granting_deferral` | `pos_integer()` | - | Determines the maximum possible amount of deferral applied on a permission set granting. | `15_552_000`
`maximum_granting_lifetime` | `pos_integer()` | seconds | Determines the maximum duration of a granting action. | `15_552_000`
`allow_infinite_lifetime` | `boolean()` | - | Allows infinite lifetime on a permission set grant. Grants with infinite lifetimes can only be invalidated manually. | `true`

### Concrete authentication

##### Path

`Legion.Identity.Auth.Concrete`

##### Parameters

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | --- | ---
`passkey_scaling` | `pos_integer()` | - | Scales the authentication passphrase by given number to increase the entropy. | `4`
`passphrase_lifetime` | `pos_integer()` | seconds | Duration of a passphrase without being invalidated. | `15_552_000`
`user_agent_length` | `pos_integer()` | - | Maximum length of the user agent string sent by the client. | `400`

### JSON Object Signing and Encoding (JOSE)

##### Path

`Legion.Identity.Auth.Concrete.JOSE`

##### Parameters

Key | Data Type | Units | Description | Default
--- | --- | --- | --- | --- | ---
`secret_key_base` | [`String.t()`] | - | Secret key used in HMAC algorithm (JWS). | *See notes (1).*
`issuer` | [`String.t()`] | - | Issuer of the JWT. | *N/A*
`lifetime` | `pos_integer()` | - | Valid duration for the JWT. | `300`
`sub` | [`String.t()`] | - | Purpose of the issue. | `access`

### Insecure authentication

##### Path

`Legion.Identity.Auth.Insecure`

##### Parameters

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | --- | ---
`allowed_cleartext_safe_artifacts` | `[t() :: :username ǀ :email]` | - | Allowed cleartext credentials of username and email. | `[:username, :email]`
`username_type` | `t() :: :alphanumeric ǀ :numeric` | - | Data type for the username. | `:alphanumeric`
`username_length` | [`Range.t()`] | - | Length of the username. | `6..20`
`bypass_concrete_auth` | `boolean()` | - | Possibility of sign in without concrete authentication. *See notes (2).* | `true`
`password_digestion` | `t() :: :bcrypt ǀ :pbkdf2 ǀ :argon2` | - | Algorithm to be used in digestion stage of the cleartext password. | `:argon2`
`password_type` | `t() :: :numeric ǀ :ascii ǀ :unicode` | - | Type of the password. | `:unicode`
`password_length` | [`Range.t()`] | - | Length of the password. | `8..32`
`password_minimum_security_level` | [`t() :: :length ǀ :chartypes ǀ :all`] | Password security level threshold. | `:all`

### OTC

##### Path

`Legion.Identity.Auth.OTC`

##### Parameters

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | --- | ---
`type` | `t() :: :alphanumeric ǀ :integer` | - | Type of the one time code. | `:integer`
`length` | `pos_integer()` | - | Length of a one time code, increases entropy. | `:integer`
`prefix` | [`String.t()`] | - | Prefix of the one time code. | *λ*
`postfix` | [`String.t()`] | - | Postfix of the one time code. | *λ*
`medium` | *See note (3).* | - | Medium adapter to be used in sending one time code. | `Legion.Identity.Auth.OTC.Adapters.SMS`

### Two-factor authentication

##### Path

`Legion.Identity.Auth.Concrete.TFA`

##### Parameters

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | --- | ---
`lifetime` | `pos_integer()` | seconds | Duration of the two-factor authentication handle. | `180`
`allowed_attempts` | `pos_integer()` | - | Number of attempts to invalidate the handle. | `3`

### Algorithm

##### Path

`Legion.Identity.Auth.Algorithm`

##### Parameters

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | --- | ---
`keccak_variant` | `t() :: :sha3_224 ǀ :sha3_256 ǀ :sha3_384 ǀ :sha3_512` | - | Keccak variant to be used in hashing passkeys. | `:sha3_512`

## Messaging/Push Gateway (MPB)

### Global switches

##### Path

`Legion.Messaging.Switching.Globals`

##### Parameters

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | --- | ---
`history_buffer_length` | [`Range.t()`] | - | Number of entries in history buffer rollback. | `5`

### APM medium

##### Path

`Legion.Messaging.Medium.APM`

##### Parameters

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | --- | ---
`subject_length` | [`Range.t()`] | - | Length of the subject of the message. | `2..40`
`body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

### Push medium

##### Path

`Legion.Messaging.Medium.Push`

##### Parameters

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | --- | ---
`subject_length` | [`Range.t()`] | - | Length of the subject of the message. | `2..40`
`body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

### Mailing medium

##### Path

`Legion.Messaging.Medium.Mailing`

##### Parameters

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | --- | ---
`subject_length` | [`Range.t()`] | - | Length of the subject of the message. | `2..40`
`body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

### SMS medium

##### Path

`Legion.Messaging.Medium.SMS`

##### Parameters

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | --- | ---
`body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

### Platform medium

##### Path

`Legion.Messaging.Medium.Platform`

##### Parameters

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | --- | ---
`subject_length` | [`Range.t()`] | - | Length of the subject of the message. | `2..40`
`body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

### Templatization

##### Path

`Legion.Messaging.Templatization`

##### Parameters

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | --- | ---
`template_name_length` | [`Range.t()`] | - | Length of the name of the template. | `5..50`

[`Range.t()`]: https://hexdocs.pm/elixir/Range.html#t:t/0
[`String.t()`]: https://hexdocs.pm/elixir/String.html#t:t/0
