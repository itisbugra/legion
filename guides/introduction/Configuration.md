# Configuring the application

Author: [Buğra Ekuklu](mailto:bekuklu@stcpay.com.sa)

### Revision history

1. Initial draft, 18-06-11, [Buğra Ekuklu](mailto:bekuklu@stcpay.com.sa).

---

Legion presents a completely opinionated authentication/authorization mechanism,
using best-practices as much as possible, however it also supports configuring
by supplying various configuration parameters in configuration files.

## Using configuration scripts

One may use a configuration script by simply creating a new `.exs` file. The
configuration script file should contain all configuration parameters of the
application.

```elixir
# legion.exs
use Mix.Config

six_months = 15_552_000

config :legion, Legion.Identity.Auth.AccessControl,
  permission_set_name_length: 4..28,
  permission_set_description_length: 8..80,
  maximum_granting_deferral: six_months,
  maximum_granting_lifetime: six_months,
  allow_infinite_lifetime: true

# other configuration calls...
```

Assuming we created a configuration script named `legion.exs`, we could then use the file
by using import macro of Mix in our main configuration file.

```elixir
# config.exs
use Mix.Config

import_config "legion.exs"
```

## Retrieving configuration values

Most of the time, implementations requiring configurable values retrieve these values from
configuration function provided by the Mix.

Legion makes use of a convention of retrieving configuration values at the compile-time by using module attributes.
For example, you can retrieve passkey scaling factor at the compile-time by following module attribute definition.

```elixir
defmodule App.SomeModule do
  @moduledoc false
  @env Application.get_env(:legion, Legion.Identity.Auth.Concrete)
  @scale Keyword.fetch!(@env, :passkey_scaling)

  # Use @scale module attribute
end
```

However, since this is a compile-time attribute, it is significant to clarify that the changes happened at the runtime are not reflected to the module attributes.

If you are not able to use module attributes directly, i.e. macro context, you may also use the `Module.get_attribute/2` function.

```elixir
defmodule App.AnotherModule do
  @moduledoc false
  @apm_env Application.get_env(:legion, Legion.Messaging.Medium.APM)
  @apm_subject_len Keyword.fetch!(@apm_env, :subject_length)

  @push_env Application.get_env(:legion, Legion.Messaging.Medium.Push)
  @push_subject_len Keyword.fetch!(@push_env, :subject_length)

  @mediums [:apm, :push]

  for medium <- @mediums do
    defp check_length(string, unquote(type)) do
      min = unquote(Module.get_attribute(__MODULE__, :"#{Atom.to_string(medium)}_subject_len"))

      if String.length(unquote(string)) >= min,
        do: :ok,
      else: :error
    end
  end
end
```

## Altering configuration values at runtime

Legion retrieves most of the configuration values at the runtime. Unless it is explicitly
specified by an external API, developers are not allowed to change the configuration values
belong to Legion itself, and the result might be undefined behavior.

```elixir
defmodule App.ImproperSwitcher do
  use Mix.Config

  def close do
    # This is invalid
    config :legion, Legion.Messaging.Medium.APM,
      is_enabled?: false
  end
end
```

```elixir
defmodule App.ProperSwitcher do
  def close do
    # Using the explicit configuration API
    disable_medium(user_id, :apm)
  end
end
```
