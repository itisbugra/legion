defmodule Legion.Identity.Auth.Algorithm.Keccak do
  @moduledoc """
  Provides functions for hashing data with FIPS-202 compliant Keccak variants.
  """
  @env Application.get_env(:legion, Legion.Identity.Auth.Algorithm)
  @variant Keyword.fetch!(@env, :keccak_variant)

  @typedoc """
  Keccak variants to be used in default hashing operations.
  """
  @type algorithm() :: :sha3_224 | :sha3_256 | :sha3_384 | :sha3_512

  @typedoc """
  The result of the algorithm.
  """
  @type hash() :: binary()

  @doc """
  Hashes the given binary with given Keccak algorithm.
  """
  @spec hash(algorithm(), binary()) :: hash()
  def hash(algorithm, data) do
    algorithm
    |> :keccakf1600.hash(data)
    |> Base.encode16()
  end

  @doc """
  Hashes the given binary with default Keccak algorithm configured.
  """
  @spec hash(binary()) :: hash()
  def hash(data), do: hash(@variant, data)
end
