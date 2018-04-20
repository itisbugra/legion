defmodule Legion.Identity.Auth.Concrete.Passkey do
  @moduledoc """
  Property representing the secure data of an access token.
  """
  alias Legion.Identity.Auth.Algorithm.Keccak

  @env Application.get_env(:legion, Legion.Identity.Auth.Concrete)
  @scale Keyword.fetch!(@env, :passkey_scaling)

  @typedoc """
  A passkey is simply a concatenation of #{@scale} UUIDs (Version 4).
  """
  @type t :: binary

  @doc """
  Generates a string passkey with an absolute length of #{@scale * 22}.
  """
  @spec generate() :: String.t
  def generate(), do: Base.encode64(bingenerate(), padding: true)

  @doc """
  Generates a binary passkey.
  """
  @spec bingenerate() :: binary
  def bingenerate() do
    Enum.map_join(1..@scale, fn(_) -> Ecto.UUID.bingenerate() end)
  end

  @doc """
  Hashes given passkey with the default Keccak variant declared in configuration file.
  """
  @spec hash(t()) :: binary()
  def hash(passkey), do: Keccak.hash(passkey)

  @doc """
  A dummy stall function in order to prevent from handle enumeration. It always return `false`.
  """
  @spec stall() :: false
  def stall() do 
    Keccak.hash("password")
    false
  end
end
