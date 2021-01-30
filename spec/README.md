# OpenAPI 3.0 Specification for Quessly

Lead maintainer: [Buğra Ekuklu](https://github.com/Chatatata)

## Generating documentation YAML

You can utilize the `generate_docs` shell script to generate the
merged documentation YAML file.

### Dependencies

- Node 8.0.2 (or later)
- NPM 6.0.0 (or later)

### Running the script

```bash
$ ./generate_docs
```

> The command will install `json-refs` package globally, if it does not exist.

You can find the generated YAML files under `build` folder in root directory of the project.
There ought to be two seperate files for specification declarations.

 1. `http.yml` for HTTP API,
 2. `ws.yml` for Streaming API.

You can use [AsyncAPI Playground](https://playground.asyncapi.io/) to see a human-readable rendering of the Streaming API, or
[Swagger Editor](https://editor.swagger.io/) for the HTTP API.
