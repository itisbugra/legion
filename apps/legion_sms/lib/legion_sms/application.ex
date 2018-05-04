defmodule LegionSMS.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: LegionSMS.Worker.start_link(arg)
      # {LegionSMS.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LegionSMS.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
