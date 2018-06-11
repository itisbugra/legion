# Configuring the application

Author: [Buğra Ekuklu](mailto:bekuklu@stcpay.com.sa)

## Preface

Legion presents a completely opinionated authentication/authorization mechanism,
using best-practices as much as possible, however it also supports configuring
by supplying various configuration parameters in configuration files.

## Subsystems

1. [Identity/Access Management (IAM)](#identityaccess-management-iam)
2. [Messaging/Push Gateway (MPB)](#messagingpush-gateway-mpb)

### 1. Identity/Access Management (IAM)

1. [Access control](#access-control)
2. [Concrete authentication](#concrete-authentication)
3. [JSON Object Signing and Encoding (JOSE)](#json-object-signing-and-encoding-jose)
4. [Insecure authentication](#insecure-authentication)
5. [OTC](#otc)
6. [Two-factor authentication](#two-factor-authentication)
7. [Persistence algorithm](#persistence-algorithm)

#### Access control

The module is configured using namespace `Legion.Identity.Auth.AccessControl`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`permission_set_name_length` | [`Range.t()`] | - | Indicates the bounds of length of a permission set name. | `4..28`
`permission_set_description_length` | [`Range.t()`] | - | Indicates the bounds of length of a permission set description. | `8..80`
`maximum_granting_deferral` | `pos_integer()` | - | Determines the maximum possible amount of deferral applied on a permission set granting. | `15_552_000`
`maximum_granting_lifetime` | `pos_integer()` | seconds | Determines the maximum duration of a granting action. | `15_552_000`
`allow_infinite_lifetime` | `boolean()` | - | Allows infinite lifetime on a permission set grant. Grants with infinite lifetimes can only be invalidated manually. | `true`

#### Concrete authentication

The module is configured using namespace `Legion.Identity.Auth.Concrete`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`passkey_scaling` | `pos_integer()` | - | Scales the authentication passphrase by given number to increase the entropy. | `4`
`passphrase_lifetime` | `pos_integer()` | seconds | Duration of a passphrase without being invalidated. | `15_552_000`
`user_agent_length` | `pos_integer()` | - | Maximum length of the user agent string sent by the client. | `400`

#### JSON Object Signing and Encoding (JOSE)

The module is configured using namespace `Legion.Identity.Auth.Concrete.JOSE`, with the following attributes.

Key | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`secret_key_base` | [`String.t()`] | - | Secret key used in HMAC algorithm (JWS). | *See notes (1).*
`issuer` | [`String.t()`] | - | Issuer of the JWT. | *N/A*
`lifetime` | `pos_integer()` | - | Valid duration for the JWT. | `300`
`sub` | [`String.t()`] | - | Purpose of the issue. | `access`

#### Insecure authentication

The module is configured using namespace `Legion.Identity.Auth.Insecure`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`allowed_cleartext_safe_artifacts` | `[t() :: :username ǀ :email]` | - | Allowed cleartext credentials of username and email. | `[:username, :email]`
`username_type` | `t() :: :alphanumeric ǀ :numeric` | - | Data type for the username. | `:alphanumeric`
`username_length` | [`Range.t()`] | - | Length of the username. | `6..20`
`bypass_concrete_auth` | `boolean()` | - | Possibility of sign in without concrete authentication. *See notes (2).* | `true`
`password_digestion` | `t() :: :bcrypt ǀ :pbkdf2 ǀ :argon2` | - | Algorithm to be used in digestion stage of the cleartext password. | `:argon2`
`password_type` | `t() :: :numeric ǀ :ascii ǀ :unicode` | - | Type of the password. | `:unicode`
`password_length` | [`Range.t()`] | - | Length of the password. | `8..32`
`password_minimum_security_level` | [`t() :: :length ǀ :chartypes ǀ :all`] | - | Password security level threshold. | `:all`

#### OTC

The module is configured using namespace `Legion.Identity.Auth.OTC`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`type` | `t() :: :alphanumeric ǀ :integer` | - | Type of the one time code. | `:integer`
`length` | `pos_integer()` | - | Length of a one time code, increases entropy. | `:integer`
`prefix` | [`String.t()`] | - | Prefix of the one time code. | *λ*
`postfix` | [`String.t()`] | - | Postfix of the one time code. | *λ*
`medium` | *See note (3).* | - | Medium adapter to be used in sending one time code. | `Legion.Identity.Auth.OTC.Adapters.SMS`

#### Two-factor authentication

The module is configured using namespace `Legion.Identity.Auth.Concrete.TFA`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`lifetime` | `pos_integer()` | seconds | Duration of the two-factor authentication handle. | `180`
`allowed_attempts` | `pos_integer()` | - | Number of attempts to invalidate the handle. | `3`

#### Persistence algorithm

The module is configured using namespace `Legion.Identity.Auth.Algorithm`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`keccak_variant` | `t() :: :sha3_224 ǀ :sha3_256 ǀ :sha3_384 ǀ :sha3_512` | - | Keccak variant to be used in hashing passkeys. | `:sha3_512`

### 2. Messaging/Push Gateway (MPB)

1. [Global switches](#global-switches)
2. [APM medium](#apm-medium)
3. [Push medium](#push-medium)
4. [Mailing medium](#mailing-medium)
5. [SMS medium](#sms-medium)
6. [Platform medium](#platform-medium)
7. [Templatization](#templatization)

#### Global switches

The module is configured using namespace `Legion.Messaging.Switching.Globals`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`history_buffer_length` | [`Range.t()`] | - | Number of entries in history buffer rollback. | `5`

#### APM medium

The module is configured using namespace `Legion.Messaging.Medium.APM`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`subject_length` | [`Range.t()`] | - | Length of the subject of the message. | `2..40`
`body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

#### Push medium

The module is configured using namespace `Legion.Messaging.Medium.Push`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`subject_length` | [`Range.t()`] | - | Length of the subject of the message. | `2..40`
`body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

#### Mailing medium

The module is configured using namespace `Legion.Messaging.Medium.Mailing`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`subject_length` | [`Range.t()`] | - | Length of the subject of the message. | `2..40`
`body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

#### SMS medium

The module is configured using namespace `Legion.Messaging.Medium.SMS`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

#### Platform medium

The module is configured using namespace `Legion.Messaging.Medium.Platform`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`subject_length` | [`Range.t()`] | - | Length of the subject of the message. | `2..40`
`body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

#### Templatization

The modules is configured using namespace `Legion.Messaging.Templatization`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`template_name_length` | [`Range.t()`] | - | Length of the name of the template. | `5..50`

## Footnotes

1. The secret key should be generated using secure random generator with increased entropy.

Quoting from [*Quickstart documentation for Flask 0.12.4*](http://flask.pocoo.org/docs/0.12/quickstart/),

> **How to generate good secret keys**
>
> The problem with random is that it’s hard to judge what is truly random. And a secret key should be as random as possible.
> Your operating system has ways to generate pretty random stuff based on a cryptographic
> random generator which can be used to get such a key (in Python REPL):
>
> `import os`
>
> `os.urandom(24)`
>
> Just take that thing and copy/paste it into your code and you're done.

2. Passphrases are meant to be stored by the client-side program. Sometimes one might not need to save
the authentication information on the device, such as public computers. This functionality is generally
provided by a checkbox *'Remember me'*, which will save the session information on cookies, or local
storage etc. When this checkbox is enabled, the server-side should not generate a passkey, but instead
return a JWT immediately, to implement the correct behavior. Hence, the client-side program should be
aware of deserialization of response sent by this application, since it may respond with either passkey
or a token, directly.

[`Range.t()`]: https://hexdocs.pm/elixir/Range.html#t:t/0
[`String.t()`]: https://hexdocs.pm/elixir/String.html#t:t/0
