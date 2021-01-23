defmodule Legion.HTTP.Application do
  @moduledoc """
  The HTTP web server interface application service.

  It runs the web interface working with JSON endpoints with the business logic managed by main
  application.
  """
  use Application

  def start(_type, _args) do
    children = [
      Legion.HTTP.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Legion.HTTP.Supervisor)
  end

  @spec config_change(any, any, any) :: :ok
  def config_change(changed, _new, removed) do
    Legion.HTTP.Endpoint.config_change(changed, removed)
    :ok
  end
end
