defmodule Legion.Mixfile do
  use Mix.Project

  def project do
    [
      app: :legion,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6.4",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Legion.Application, []},
      extra_applications: [:logger, :runtime_tools, :ua_inspector, :liquid]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 2.1"},
      {:ecto_enum, "~> 1.1"},
      {:comeonin, "~> 4.0"},
      {:argon2_elixir, "~> 1.2"},
      {:bcrypt_elixir, "~> 1.0"},
      {:pbkdf2_elixir, "~> 0.12.3"},
      {:jose, "~> 1.8"},
      {:ua_inspector, "~> 0.14.0"},
      {:freegeoip, "~> 0.0.5"},
      {:inet_cidr, "~> 1.0"},
      {:ex_machina, "~> 2.1", only: :test},
      {:rsa_ex, "~> 0.2.1"},
      {:keccakf1600, "~> 2.0.0"},
      {:liquid, "~> 0.8.0"},
      {:entropy_string, "~> 1.3"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "legion.reg"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "legion.reg.all": ["legion.reg.locale", "legion.reg.messaging"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
