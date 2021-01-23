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
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
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
  defp elixirc_paths(:test), do: ["lib", "test/support", "test/stubs"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:postgrex, "~> 0.15.8"},
      {:ecto_sql, "~> 3.5"},
      {:ecto_enum, "~> 1.4.0"},
      {:comeonin, "~> 5.3.2"},
      {:argon2_elixir, "~> 2.4.0"},
      {:bcrypt_elixir, "~> 2.3.0"},
      {:pbkdf2_elixir, "~> 1.3.0"},
      {:jose, "~> 1.11.1"},
      {:ua_inspector, "~> 2.2.0"},
      {:freegeoip, "~> 0.0.5"},
      {:inet_cidr, "~> 1.0.4"},
      {:ex_machina, "~> 2.5.0", only: :test},
      {:rsa_ex, "~> 0.4.0"},
      {:keccakf1600, "~> 2.0.0", hex: :keccakf1600_orig},
      {:liquid, "~> 0.9.1"},
      {:entropy_string, "~> 1.3.4"},
      {:nimble_csv, "~> 1.1.0"},
      {:cidr, "~> 1.1.0"},
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false},
      {:ex_phone_number, "~> 0.2.1"},
      {:phoenix, "~> 1.5.7"},
      {:poison, "~> 4.0", override: true}
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
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
