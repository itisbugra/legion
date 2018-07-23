defmodule Legion.Networking.INET do
  @moduledoc """
  Provides functions and types for INET data structures.
  """
  import CIDR, only: [match!: 2, parse: 1]

  alias Legion.Networking.INET

  @typedoc """
  Type of the IP address.
  """
  @type t() :: :inet.ip_address()
  
  @type error_type() :: atom()

  @spec validate_addr(INET.t()) :: 
    :ok |
    {:error, error_type()}
  def validate_addr(inet) do
    Enum.reduce_while(constraints(), :ok, fn {cidr, error}, _acc ->
      if validate_inclusion(inet, cidr) do
        {:halt, {:error, error}}
      else
        {:cont, :ok}
      end
    end)
  end

  defp validate_inclusion(inet, cidr) do
    cidr
    |> parse()
    |> match!(inet)
  end

  defp constraints do
    [
      {"0.0.0.0/8", :self_reference},
      {"10.0.0.0/8", :private_use},
      {"127.0.0.0/8", :loopback},
      {"169.254.0.0/16", :link_local},
      {"172.16.0.0/12", :private_use},
      {"192.0.0.0/24", :ietf_protocol_assn},
      {"192.0.2.0/24", :test_net},
      {"192.88.99.0/24", :bridge_relay_anycast},
      {"192.168.0.0/16", :private},
      {"198.18.0.0/15", :network_interconnect},
      {"198.51.100.0/24", :test_net},
      {"203.0.113.0/24", :test_net},
      {"224.0.0.0/4", :multicast},
      {"240.0.0.0/4", :reserved},
      {"255.255.255.255/32", :limited_broadcast}
    ]
  end
end