defmodule Legion.Umbrella.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test,
                          "coveralls.detail": :test,
                          "coveralls.post": :test,
                          "coveralls.html": :test]
    ]
  end

  defp deps do
    [{:ex_doc, "~> 0.16", only: :dev, runtime: false},
     {:excoveralls, "~> 0.8.0", only: :test}]
  end

  defp aliases do
    ["ecto.setup": ["ecto.create",
                    "ecto.migrate",
                    "run apps/legion/priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop",
                    "ecto.setup"],
     "legion.reg": ["legion.reg.locale",
                    "legion.reg.messaging"],
     "legion.bootstrap": ["legion.reg",
                          "ua_inspector.download.short_code_maps",
                          "ua_inspector.download.short_code_maps",
                          "ecto.setup"]]
  end
end
