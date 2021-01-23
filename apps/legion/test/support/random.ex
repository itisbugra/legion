defmodule Legion.Testing.Random do
  @moduledoc """
  Provides utility functions for generating random data.
  """
  @alphabet "0123456789abcdefghijklmnopqrstuvwyzABCDEFGHIJKLOPQRSTUVWYZ"

  @doc """
  Generates a random string with given length (or range).
  Useful for generating test data in certain length.
  """
  def random_string(len) when is_integer(len) do
    Enum.map_join(1..len, fn _ ->
      String.at(@alphabet, :rand.uniform(String.length(@alphabet)) - 1)
    end)
  end

  def random_string(range) when is_map(range) do
    len = :rand.uniform(Enum.max(range) - Enum.min(range)) + Enum.min(range)

    random_string(len)
  end
end
