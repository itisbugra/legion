defmodule Legion.Identity.Auth.Concrete.Passkey do
  @moduledoc """
  Property representing the secure data of an access token.
  """
  alias Legion.Identity.Auth.Algorithm.Keccak

  @env Application.get_env(:legion, Legion.Identity.Auth.Concrete)
  @scale Keyword.fetch!(@env, :passkey_scaling)
  @cofactor 1024

  @typedoc """
  A passkey is simply a random string consisting of #{@scale * @cofactor} entropy bits.
  """
  @type t() :: binary()

  @doc """
  Generates a string passkey with an entropy size of #{@scale * @cofactor}.
  """
  @spec generate() :: String.t
  def generate(), do: EntropyString.random(@scale * @cofactor, :charset64)

  @doc """
  Generates a binary passkey.
  """
  @spec bingenerate() :: binary()
  def bingenerate(), do: Base.url_decode64!(generate(), padding: false)

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
