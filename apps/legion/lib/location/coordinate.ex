defmodule Legion.Location.Coordinate do
  @moduledoc """
  Provides functions and data structures for two-dimensional coordinates.
  """

  @typedoc """
  Represents a two-dimensional coordinate on surface.
  """
  @type t() :: Postgrex.Point.t()
end
