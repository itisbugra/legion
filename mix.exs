defmodule Legion.Umbrella.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      docs: docs(),
      elixir: "~> 1.11",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.23.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.13.4", only: :test},
      {:credo, "~> 1.5.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run apps/legion/priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "legion.reg": [
        "legion.reg.locale",
        "legion.reg.nationality",
        "legion.reg.messaging",
        "legion.reg.political"
      ],
      "legion.check": ["legion.check.timezone"],
      "legion.setup": [
        "legion.check",
        "ecto.setup",
        "legion.reg",
        "ua_inspector.download -f"
      ],
      "legion.reset": ["legion.check", "ecto.reset", "legion.reg"]
    ]
  end

  def docs do
    [
      name: "Legion",
      main: "up-and-running",
      source_url: "http://95.177.215.207/STMS/Chat/Legion",
      extra_section: "GUIDES",
      extras: extras(),
      groups_for_extras: groups_for_extras(),
      groups_for_modules: groups_for_modules()
    ]
  end

  def extras do
    [
      "guides/introduction/Up and Running.md",
      "guides/introduction/Configuration.md",
      "guides/iam/Preface-IAM.md",
      "guides/iam/Configuration-IAM.md",
      "guides/mpb/Preface-MPB.md",
      "guides/mpb/Configuration-MPB.md"
    ]
  end

  def groups_for_extras do
    [
      "Getting Started": ~r/guides\/introduction\/.?/,
      "Identity & Access Management": ~r/guides\/iam\/.?/,
      "Messaging Relay & Push": ~r/guides\/mpb\/.?/
    ]
  end

  def groups_for_modules do
    [
      "Identity and Access Control": [
        Legion.Identity.Auth.AccessControl.ControllerAction,
        Legion.Identity.Auth.AccessControl.Permission,
        Legion.Identity.Auth.AccessControl.PermissionSet,
        Legion.Identity.Auth.AccessControl.PermissionSetCache,
        Legion.Identity.Auth.AccessControl.PermissionSetGrant,
        Legion.Identity.Auth.AccessControl.PermissionSetCacheEntry
      ]
    ]
  end
end
