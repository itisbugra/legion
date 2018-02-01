defmodule LegionWeb.Application do
  @moduledoc """
  The HTTP web server interface application service.

  It runs the web interface working with JSON endpoints with the business logic managed by main
  application.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(LegionWeb.Endpoint, []),
      # Start your own worker by calling: LegionWeb.Worker.start_link(arg1, arg2, arg3)
      # worker(LegionWeb.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LegionWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LegionWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
