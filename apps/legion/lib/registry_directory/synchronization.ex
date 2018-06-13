defmodule Legion.RegistryDirectory.Synchronization do
  @moduledoc """
  Synchronization support for managing registry keys.

  ### Creating a synchronization task

  A synchronization module can help for creating keys, and checking them at
  the time of the migration. If all keys do exist, running the task should be
  no-op.

  ```
  defmodule Mix.Tasks.Foo.Reg.Birds do
    use Legion.RegistryDirectory.Synchronization, site: Foo.Birds, repo: Foo.Repo

    @shortdoc "Synchronizes bird registers"

    require Logger

    alias Foo.Repo
    alias Foo.Birds.Register

    def register(key),
      do: Repo.insert(%Register{key: key})

    def sync do
      register "hummingbird"
      register "auk"
      register "blackbird"
      register "chickadee"
      register "dove"
      register "duck"
      register "nuthatch"
      register "seabird"
    end
  end
  ```
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
      end
    end
  end
end
