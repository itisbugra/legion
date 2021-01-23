use Mix.Config

config :legion, ecto_repos: [Legion.Repo]

import_config "#{Mix.env}.exs"
