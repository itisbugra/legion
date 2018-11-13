defmodule Legion.Types.CIDR do
  @moduledoc """
  Support for using Ecto with `:cidr` fields.
  """
  import InetCidr, only: [parse: 2]

  @behaviour Ecto.Type

  def type, do: :cidr

  @doc """
  Handles casting to `Postgrex.INET`.
  """
  def cast(%Postgrex.INET{} = address), do: {:ok, address}

  def cast(address) when is_binary(address) do
    try do
      case parse(address, false) do
        {start_address, _end_address, netmask} ->
          {:ok, %Postgrex.INET{address: start_address, netmask: netmask}}

        {:error, _einval} ->
          :error
      end
    rescue
      _ -> :error
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
  def decode(%Postgrex.INET{address: _address, netmask: nil}), do: :error

  def decode(%Postgrex.INET{address: address, netmask: netmask}) do
    case :inet.ntoa(address) do
      {:error, _einval} -> :error
      formatted_address -> "#{List.to_string(formatted_address)}/#{netmask}"
    end
  end
end
