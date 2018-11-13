defmodule Legion.Mix.Check.Timezone.UnknownTimeZoneError do
  defexception [:timezone]

  def exception(timezone),
    do: %__MODULE__{timezone: timezone}

  def message(%__MODULE__{timezone: timezone}),
    do: "the timezone setting of the database is not UTC, but #{timezone} instead"
end

defmodule Mix.Tasks.Legion.Check.Timezone do
  @moduledoc """
  Run before starting any task to check the timezone of the database.
  """
  require Logger

  import Mix.Ecto

  alias Legion.Repo
  alias Legion.Mix.Check.Timezone.UnknownTimeZoneError

  Logger.configure(level: :info)

  @doc false
  def run(args) do
    repos = parse_repo(args)
    {_, _, _} = OptionParser.parse(args, switches: [quiet: :boolean])

    Enum.each(repos, fn repo ->
      ensure_repo(repo, args)

      Mix.shell().info("== Checking timezone configuration")

      {:ok, %Postgrex.Result{rows: [[tz]]}} = Repo.query("SHOW TIME ZONE", [], log: false)

      if tz == "UTC" do
        Mix.shell().info("time zone = UTC")
      else
        Mix.raise(UnknownTimeZoneError, tz)
      end

      Mix.shell().info("== Finished checking timezone configuration")
    end)
  end
end
