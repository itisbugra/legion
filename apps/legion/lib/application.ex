defmodule Legion.Application do
  @moduledoc """
  Application service for the Legion.

  The business domain lives in this application.

  Exposes API to clients such as the `LegionWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    children = [Legion.Repo]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
