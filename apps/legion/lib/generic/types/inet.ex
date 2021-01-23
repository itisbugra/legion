defmodule Legion.Types.INET do
  @moduledoc """
  Support for using Ecto with `:inet` fields.
  """
  @behaviour Ecto.Type

  def type, do: :inet

  @doc """
  Defines an embedding format for the object.
  """
  def embed_as(_), do: :self

  @doc """
  Compares two objects of this type.
  """
  def equal?(left, right), do: left == right

  @doc """
  Handles casting to `Postgrex.INET`.
  """
  def cast(%Postgrex.INET{} = address), do: {:ok, address}

  def cast(address) when is_binary(address) do
    case parse_address(address) do
      {:ok, parsed_address} -> {:ok, %Postgrex.INET{address: parsed_address}}
      {:error, _einval} -> :error
    end
  end

  def cast(_), do: :error

  @doc """
  Loads from the native Ecto representation.
  """
  def load(%Postgrex.INET{} = address), do: {:ok, address}
  def load(_), do: :error

  @doc """
  Converts to the native Ecto representation.
  """
  def dump(%Postgrex.INET{} = address), do: {:ok, address}
  def dump(_), do: :error

  @doc """
  Converts from native Ecto representation to a binary.
  """
  def decode(%Postgrex.INET{address: address, netmask: nil}) do
    case :inet.ntoa(address) do
      {:error, _einval} -> :error
      formatted_address -> List.to_string(formatted_address)
    end
  end

  def decode(%Postgrex.INET{}), do: :error

  defp parse_address(address) do
    address |> String.to_charlist() |> :inet.parse_address()
  end
end

# see https://github.com/elixir-ecto/postgrex/issues/383
defimpl String.Chars, for: Postgrex.INET do
  def to_string(%Postgrex.INET{netmask: nil} = address), do: Legion.Types.INET.decode(address)
  def to_string(%Postgrex.INET{} = address), do: Legion.Types.CIDR.decode(address)
end
