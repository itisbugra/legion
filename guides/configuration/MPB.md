# MPB

Author: [Buğra Ekuklu](mailto:bekuklu@stcpay.com.sa)

### Revision history

1. Initial draft, 18-06-14, [Buğra Ekuklu](mailto:bekuklu@stcpay.com.sa).

---

## Global switches

The module is configured using namespace `Legion.Messaging.Switching.Globals`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`:history_buffer_length` | [`Range.t()`] | - | Number of entries in history buffer rollback. | `5`

## APM medium

The module is configured using namespace `Legion.Messaging.Medium.APM`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`:subject_length` | [`Range.t()`] | - | Length of the subject of the message. | `2..40`
`:body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`:is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

## Push medium

The module is configured using namespace `Legion.Messaging.Medium.Push`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`:subject_length` | [`Range.t()`] | - | Length of the subject of the message. | `2..40`
`:body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`:is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

## Mailing medium

The module is configured using namespace `Legion.Messaging.Medium.Mailing`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`:subject_length` | [`Range.t()`] | - | Length of the subject of the message. | `2..40`
`:body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`:is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

## SMS medium

The module is configured using namespace `Legion.Messaging.Medium.SMS`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`:body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`:is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

## Platform medium

The module is configured using namespace `Legion.Messaging.Medium.Platform`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`:subject_length` | [`Range.t()`] | - | Length of the subject of the message. | `2..40`
`:body_length` | [`Range.t()`] | - | Length of the body of the message. | `5..255`
`:is_enabled` | `boolean()` | - | Compile-time switch to enable the medium. | `true`

## Templatization

The modules is configured using namespace `Legion.Messaging.Templatization`, with the following attributes.

Parameter name | Data Type | Units | Description | Default
--- | --- | --- | --- | ---
`:template_name_length` | [`Range.t()`] | - | Length of the name of the template. | `5..50`
