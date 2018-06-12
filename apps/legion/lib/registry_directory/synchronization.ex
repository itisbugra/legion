defmodule Legion.RegistryDirectory.Synchronization do
  @moduledoc """
  Provides synchronization support for managing registry keys.
  """

  @doc false
  defmacro __using__(kwargs) do
    quote location: :keep do
      @site Keyword.fetch!(unquote(kwargs), :site)
      @repo Keyword.fetch!(unquote(kwargs), :repo)

      if Code.ensure_loaded?(unquote(__MODULE__)) do
        use Mix.Task

        require Logger

        import Mix.Ecto

        def run(_args) do
          {:ok, pid, _apps} = ensure_started(@repo, [])
          sandbox? = @repo.config[:pool] == Ecto.Adapters.SQL.Sandbox

          if sandbox? do
            Ecto.Adapters.SQL.Sandbox.checkin(@repo)
            Ecto.Adapters.SQL.Sandbox.checkout(@repo, sandbox: false)
          end

          Logger.info fn ->
            "== Adding #{@site} registers"
          end

          sync()

          sandbox? && Ecto.Adapters.SQL.Sandbox.checkin(@repo)

          pid && @repo.stop(pid)

          Logger.info fn ->
            "== Finished migrating #{@site} registers"
          end
        end
      else
        raise "zaa"
      end
    end
  end
end
