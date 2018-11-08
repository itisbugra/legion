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

  def run(_args) do
    {:ok, pid, _apps} = ensure_started(Repo, [])
    sandbox? = Repo.config()[:pool] == Ecto.Adapters.SQL.Sandbox

    if sandbox? do
      Ecto.Adapters.SQL.Sandbox.checkin(Repo)
      Ecto.Adapters.SQL.Sandbox.checkout(Repo, sandbox: false)
    end

    Logger.info("== Checking timezone configuration")

    {:ok, %Postgrex.Result{rows: [[tz]]}} = Repo.query("SHOW TIME ZONE", [], log: false)

    if tz == "UTC" do
      Logger.info("time zone = UTC")
    else
      raise UnknownTimeZoneError, tz
    end

    sandbox? && Ecto.Adapters.SQL.Sandbox.checkin(Repo)

    pid && Repo.stop(pid)

    Logger.info("== Finished checking timezone configuration")
  end
end
