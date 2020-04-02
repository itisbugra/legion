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

        import Mix.Ecto

        def run(args) do
          repos = parse_repo(args)
          {opts, _, _} = OptionParser.parse(args, switches: [quiet: :boolean])

          Enum.each(repos, fn repo ->
            ensure_repo(repo, args)

            pool = repo.config[:pool]

            Mix.shell().info("== Adding #{@site} registers")

            sync()

            Mix.shell().info("== Finished migrating #{@site} registers")

            repo.stop()
          end)
        end
      end
    end
  end
end
