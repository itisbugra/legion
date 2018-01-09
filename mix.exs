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

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [{:ex_doc, "~> 0.16", only: :dev, runtime: false},
     {:excoveralls, "~> 0.8.0", only: :test}]
  end

  defp aliases do
    ["ecto.setup": ["ecto.create",
                    "ecto.migrate",
                    "run apps/legion/priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop",
                    "ecto.setup"],]
  end
end
