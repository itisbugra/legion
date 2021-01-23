defmodule Mix.Tasks.Legion.Check.Timezone do
  @moduledoc """
  Run before starting any task to check the timezone of the database.
  """
  import Mix.Ecto

  @doc false
  def run(args) do
    Mix.Task.run("app.start")
    repos = parse_repo(args)

    Enum.each(repos, fn repo ->
      Mix.shell().info("== Checking timezone configuration")

      {:ok, %Postgrex.Result{rows: [[tz]]}} = repo.query("SHOW TIME ZONE", [], log: false)

      if tz == "UTC" do
        Mix.shell().info("time zone = UTC")
      else
        Mix.raise("the timezone setting of the database is not UTC, but #{tz} instead")
      end

      Mix.shell().info("== Finished checking timezone configuration")
    end)
  end
end
