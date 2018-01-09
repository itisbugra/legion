defmodule Legion.Types.Point do
  @moduledoc """
  Support for using Ecto with `:point` fields.
  """
  @behaviour Ecto.Type

  def type, do: :point

  @doc """
  Handles casting to `Postgrex.Point`.
  """
  def cast(%Postgrex.Point{} = point), do: {:ok, point}
  def cast(_), do: :error

  @doc """
  Loads from the native Ecto representation.
  """
  def load(%Postgrex.Point{} = point), do: {:ok, point}
  def load(_), do: :error

  @doc """
  Converts to the native Ecto representation.
  """
  def dump(%Postgrex.Point{} = point), do: {:ok, point}
  def dump(_), do: :error

  @doc """
  Converts from native Ecto representation to a binary.
  """
  def decode(%Postgrex.Point{x: x, y: y}), do: "(#{x}, #{y})"
  def decode(_), do: :error
end

defimpl String.Chars, for: Postgrex.Point do
  def to_string(%Postgrex.Point{} = point), do: Legion.Types.Point.decode(point)
end
