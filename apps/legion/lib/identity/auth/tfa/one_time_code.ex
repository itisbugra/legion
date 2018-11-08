defmodule Legion.Identity.Auth.TFA.OneTimeCode do
  @moduledoc """
  One time codes allow users to enable two-factor authentication (2FA). One may decide to use
  OTCs with SMS or e-mail. OTC is server-generated, and it cannot be resembled by any client.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Auth.Algorithm.Keccak

  @typedoc """
  Type of a one-time-code.
  """
  @type format() :: :integer | :alphanumeric

  @typedoc """
  """
  @type algorithm() :: :argon2 | :bcrypt | :pbkdf2

  @typedoc """
  Represents resulting artifact of generator functions.
  """
  @type t() :: binary()

  @env Application.get_env(:legion, Legion.Identity.Auth.OTC)
  @prefix Keyword.fetch!(@env, :prefix)
  @postfix Keyword.fetch!(@env, :postfix)
  @length Keyword.fetch!(@env, :length)
  @default_type Keyword.fetch!(@env, :type)
  @base 10
  @upper_bound round(:math.pow(@base, @length))
  @lower_bound round(:math.pow(@base, @length - 1) + 1)
  @rand_bytes_take_integer 8
  @rand_bytes_take_alphanumeric 32

  @doc """
  Generates a one-time-code in given type.
  """
  @spec generate(format()) :: t()
  def generate(:integer) do
    @rand_bytes_take_integer
    |> :crypto.strong_rand_bytes()
    |> Base.encode16()
    |> Integer.parse(16)
    |> Kernel.elem(0)
    |> Kernel.rem(@upper_bound - @lower_bound)
    |> Kernel.+(@lower_bound)
    |> Integer.to_string()
    |> wrap()
  end

  def generate(:alphanumeric) do
    @rand_bytes_take_alphanumeric
    |> :crypto.strong_rand_bytes()
    |> Base.encode32(padding: false)
    |> String.slice(0..(@length - 1))
  end

  @doc """
  Generates a one-time-code with type declared in configuration. Use `generate/1` to explicitly
  set the type instead.
  """
  @spec generate() :: t()
  def generate(), do: generate(@default_type)

  @doc """
  Hashes given one-time-code with the default Keccak variant declared in configuration file.
  """
  @spec hash(t()) :: binary()
  def hash(otc) do
    otc
    |> parse()
    |> Keccak.hash()
  end

  @doc """
  A dummy stall function in order to prevent from handle enumeration. It always return `false`.
  """
  @spec stall() :: false
  def stall() do
    Keccak.hash("password")
    false
  end

  defp parse(otc) do
    lower_bound = String.length(@prefix)
    upper_bound = String.length(otc) - String.length(@postfix)

    String.slice(otc, lower_bound..upper_bound)
  end

  defp wrap(result), do: "#{@prefix}#{result}#{@postfix}"
end
