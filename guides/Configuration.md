# Configuration

Legion presents a completely opinionated authentication/authorization mechanism, 
using best-practices as much as possible, however it also supports configuring 
by supplying various configuration parameters in configuration files.

### Access control configuration
- `permission_set_name_length`: Indicates the bounds of length of a permission
set name. Should be a `range`.
- `permission_set_description_length:`: Indicates the bounds of length of a
permission set description. Should be a `range`.
- `maximum_granting_deferral`: Determines the maximum possible amount of deferral applied on a
permission set granting. Should be an `integer`.
- `maximum_granting_lifetime`: Determines the maximum possible amount 
- `allow_infinite_lifetime`: Allows infinite lifetime on a permission set grant. Grants with
infinite lifetimes can only be invalidated manually.
