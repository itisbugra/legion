# @werkzeug / Legion

Central repository for the server-side installation of Werkzeug.

## Installation

Install the umbrella dependencies, configure the project from the configuration files located in `**/config/${ENVIRONMENT}.exs`.
To scaffold the database and download the databases for reverse IP geocoding, you can use the Mix task.

To give an illustration, we're going to run the unit tests with the following commands.

```sh
$ MIX_ENV=test mix deps.get      # Retrieve the project dependencies
$ MIX_ENV=test mix legion.setup  # Scaffold database and download specific files (such as MaxGeoIP databases)
$ mix test                       # Run ExUnit testing suite
```

## Documentation

You can build the docs by using ExDoc's Mix task.

```sh
$ mix docs
```

## License

Licensed under Apache-2, see [LICENSE](https://github.com/Chatatata/Legion/blob/master/LICENSE).
