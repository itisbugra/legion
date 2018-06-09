defmodule Legion.Logger.Verbose do
  @moduledoc """
  A module for logging into the console in verbose form.
  """
  import Kernel, except: [apply: 2]

  @colors %{
    debug: "\e[0;36m",
    info: "\e[0;32m",
    warning: "\e[0;33m",
    error: "\e[0;31m"
  }

  @nodename "\e[0;34m"
  @bold "\e[0;1m"

  def format(level, message, timestamp, metadata) do
    "$date $time #{apply("$node", @nodename)}#{bold(">")} #{colorify("$message", level)}\e[0\n"
    |> Logger.Formatter.compile()
    |> Logger.Formatter.format(level, message, timestamp, metadata)
  end

  defp colorify(string, level),
    do: Kernel.apply(__MODULE__, level, [string])

  def bold(string),
    do: apply(string, @bold)

  def debug(string),
    do: apply(string, @colors.debug)

  def info(string),
    do: apply(string, @colors.info)

  def warn(string),
    do: apply(string, @colors.warning)

  def error(string),
    do: apply(string, @colors.error)

  def apply(string, prefix),
    do: "#{prefix}#{string}"
end
