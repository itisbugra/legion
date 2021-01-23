defmodule Legion.Networking.HTTP.UserAgent do
  @moduledoc """
  Definitions for user agents of HTTP clients.
  """
  alias UAInspector, as: UserAgentParser

  @typedoc """
  Describes a user agent.
  """
  @type t() :: String.t()

  def parse(user_agent) do
    result = UserAgentParser.parse(user_agent)

    replace_unknowns(result)
  end

  defp replace_unknowns(map) do
    map
    |> Map.keys()
    |> Enum.reduce(map, fn key, acc ->
      value = Map.fetch!(acc, key)

      cond do
        is_map(value) ->
          Map.replace!(acc, key, replace_unknowns(value))
        value == :unknown ->
          Map.replace!(acc, key, nil)
        true ->
          acc
      end
    end)
  end
end