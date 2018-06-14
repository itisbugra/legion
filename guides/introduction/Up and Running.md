# Up and running

Author: [Buğra Ekuklu](mailto:bekuklu@stcpay.com.sa)

### Revision history

1. Initial draft, 18-06-14, [Buğra Ekuklu](mailto:bekuklu@stcpay.com.sa).

---

## Prerequisites

To run Legion, you need to have following applications running.

Name | Version | Docker image | Host | Additional information
:-- | :-- | :-- | :-- | :--
PostgreSQL | 10.4 | [`postgres`](https://hub.docker.com/_/postgres/) | `postgres:5432` | [Website](https://www.postgresql.org)
Freegeoip | 3.5.0 | [`fiorix/freegeoip`](https://hub.docker.com/r/fiorix/freegeoip/) | `fiorix-freegeoip:8080` | [Website](https://github.com/apilayer/freegeoip)

Legion connects to those applications with respective hostnames.
It is recommended to install those applications as Docker services.

### Elixir 1.6.5 or later

The application is written in Elixir, you might check out instructions here to install it.
If you are installed Elixir and using it for the first time, you will need to install [Hex.pm] package manager.
[Hex.pm] is necessary to install all of the application dependencies for the Legion.
You may run the following command to install it, or update the local Mix task.

```
$ mix local.hex --force
```

### Erlang 20 or later

Elixir code compiles to Erlang byte code, which runs on a virtual machine called [BEAM].
Our application is also dependent to few Erlang libraries, compiled by the [Rebar3] build tool.
Similarly to installing [Hex.pm], you might install local Mix task for [Rebar3] with the following command.


```
$ mix local.rebar --force
```

## Installing dependencies

Dependencies can be installed by using [Hex.pm] package manager and [Rebar3] build tool.
To install those tools and the dependencies of the application, you may run the following.

```
$ mix deps.get
```

## Setting up the application environment

Legion needs to execute certain actions in the environment to operate.
Those actions contain database migrations, bootstrapping etc.
You need to run setup script for once to run the application.

```
$ mix legion.setup
```

The command will create the database, insert the registrations, perform the migrations
and finally download datasets for particular features (i.e. IP reverse geocoding).

#### Setting up the PostgreSQL

Legion handles migrations, and all other types of schema manipulations automatically.
However, you might need to set the proper timezone in its configuration file, since our application uses naive date-times (timestamps without timezones) to persist server-side created time codes.

In `postgresql.conf`, you will need to change following entries to respective values to set the default timezone for the database to UTC.

```
log_timezone = 'UTC'
timezone = 'UTC'
```

Afterwards, you should restart the PostgreSQL server to make changes in effect.

## Configuration

Head over to [configuration](configuration.html) to configure the behavior of the application, enable and disable particular features by simply editing respective configuration files.

## Running

Currently, the web interface is not implemented.
Nevertheless, you can load the umbrella application to the *Interactive Elixir - IEx*.

```
$ iex -S mix run
```

## Tests

The application codebase is extensively tested with unit tests using [ExUnit].

```
$ mix test
```

You can also measure code coverage by using [ExCoveralls].

```
$ MIX_ENV=test mix coveralls        # plain-text output
$ MIX_ENV=test mix coveralls.html   # HTML output
```

Or, you may use the convenience command, which behaves identical to the former command allowing you to get plain-text coverage information.

```
$ mix test --cover
```

[Hex.pm]: https://hex.pm
[Rebar3]: http://www.rebar3.org
[BEAM]: https://en.wikipedia.org/wiki/BEAM_(Erlang_virtual_machine)
[ExUnit]: https://hexdocs.pm/ex_unit/ExUnit.html
[ExCoveralls]: https://hex.pm/packages/excoveralls
