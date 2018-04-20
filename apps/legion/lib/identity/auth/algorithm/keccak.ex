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

  @doc """
  Hashes the given binary with given Keccak algorithm.
  """
  @spec hash(algorithm(), binary()) :: binary()
  # FIXME: Algorithm should be supplied to the hash implementation.
  # Arguments are duplicated on calls made.
  def hash(_alg, data), do: :keccakf1600.hash(:sha3_512, data)

  @doc """
  Hashes the given binary with default Keccak algorithm configured.
  """
  @spec hash(binary()) :: binary()
  def hash(data), do: hash(@variant, data)
end
