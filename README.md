# Quessly server-side infrastructure: Legion

Central repository for the server-side installation of **Quessly**.

![CI status](https://github.com/Chatatata/Legion/workflows/build/badge.svg)
[![codecov](https://codecov.io/gh/Chatatata/Legion/branch/master/graph/badge.svg?token=eQNDGxuPY7)](https://codecov.io/gh/Chatatata/Legion)
[![Docs available](https://img.shields.io/static/v1?label=docs&message=available&color=informational)](https://chatatata.github.io/legion)
[![OpenAPI specs available](https://img.shields.io/static/v1?label=openapi&message=available&color=orange)](https://github.com/Chatatata/legion/tree/openapi-specs)

Lead maintainer: [Buğra Ekuklu](ekuklu@icloud.com)

## What is this?

It is a toy-project of [mine](https://github.com/Chatatata), containing server-side implementation of a platform called Quessly.

> **Quessly** is a platform, where you can solve, write questions and do examinations as a both student or teacher.
> It will be supported in mobile platforms, such as *iOS* and *Android*, as well as desktop operating systems, *Windows* and *macOS*.
> The platform aims to combine power, mobility and portability of the smartphones and personal computers in the field of education.
> It is expected to be released in *2021-Q4*.

It is empowered by the technologies found in the Elixir ecosystem, and tries to be one of the good examples of it.
This application features the following libraries. The list is not exhaustive.

- [Phoenix Framework](https://github.com/phoenixframework/phoenix)
- [Ecto](https://github.com/elixir-ecto/ecto)
- [Absinthe](https://github.com/absinthe-graphql/absinthe)
- [Mix](https://hexdocs.pm/mix/Mix.html)
- [ExMachina](https://github.com/thoughtbot/ex_machina)
- [NimbleCSV](https://github.com/dashbitco/nimble_csv)
- [Dialyzer (via Dialyxir)](https://github.com/jeremyjh/dialyxir)
- [Poison](https://github.com/devinus/poison)
- [ExUnit](https://hexdocs.pm/ex_unit/ExUnit.html)

## How to use it?

Install the umbrella dependencies, configure the project from the configuration files located in `**/config/${ENVIRONMENT}.exs`.
To scaffold the database and download the databases for reverse IP geocoding, you can use the Mix task.

To give an illustration, we're going to run the unit tests with the following commands.

```sh
$ MIX_ENV=test mix deps.get      # retrieve the project dependencies
$ MIX_ENV=test mix legion.setup  # scaffold database and download 
                                 # specific files (such as MaxGeoIP databases)
$ mix test                       # run ExUnit testing suite
```

### Documentation

You can build the docs by using **ExDoc**'s Mix task.

```sh
$ mix docs
```

### Tests

You can run the tests by using the Mix task of **ExUnit**.

```sh
$ mix test --trace              # although you can remove the --trace
                                # flag to show solely failing tests
```

### Code coverage

You can also calculate the code coverage by running the Mix task of **ExCoveralls**.

```sh
$ mix coverage.html --umbrella
```

An HTML-formatted coverage report will be located in the `/coverage` folder after 
running the command successfully.

#### Sunburst graph

![Current sunburst](https://codecov.io/gh/Chatatata/legion/branch/master/graphs/sunburst.svg)

## License

Licensed under Apache-2, see [LICENSE](https://github.com/Chatatata/legion/blob/main/LICENSE).
