defmodule Legion.Identity.Auth.TFA.OneTimeCode do
  @moduledoc """
  One time codes allow users to enable two-factor authentication (2FA). One may decide to use
  OTCs with SMS or e-mail. OTC is server-generated, and it cannot be resembled by any client.
  """
  use Legion.Stereotype, :model

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
  @digestion Keyword.fetch!(@env, :digestion)
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
  Hashes given one-time-code with the digestion algorithm declared in configuration file.
  """
  @spec hashpwsalt(t()) :: binary()
  def hashpwsalt(otc) do
    otc
    |> parse()
    |> hashpwsalt(@digestion)
  end

  @doc """
  Hashes given one-time-code with given algorithm.

  Use `hashpwsalt/1` convenience function to rely on configuration.
  """
  @spec hashpwsalt(t(), algorithm()) :: binary()
  def hashpwsalt(otc, :bcrypt), do: Comeonin.Bcrypt.hashpwsalt(otc)
  def hashpwsalt(otc, :argon2), do: Comeonin.Argon2.hashpwsalt(otc)
  def hashpwsalt(otc, :pbkdf2), do: Comeonin.Pbkdf2.hashpwsalt(otc)

  @doc """
  Performs a password check on given one-time-code with corresponding hash, returns truthy value
  if check was successful.
  """
  @spec checkpw(binary(), binary()) :: boolean()
  def checkpw(otc, hash) when is_binary(otc) and is_binary(hash) do
    otc
    |> parse()
    |> checkpw(hash, @digestion)
  end

  @doc """
  Performs a password check on given one-time-code with given hash checking function, returns 
  truthy value.

  Use `checkpw/0` convenience function to rely on configuration.
  """
  @spec checkpw(t(), binary(), algorithm()) :: boolean()
  def checkpw(otc, hash, :bcrypt), do: Comeonin.Bcrypt.checkpw(otc, hash)
  def checkpw(otc, hash, :argon2), do: Comeonin.Argon2.checkpw(otc, hash)
  def checkpw(otc, hash, :pbkdf2), do: Comeonin.Pbkdf2.checkpw(otc, hash)

  @doc """
  A dummy password check function in order to prevent from user enumeration.

  See documentations for `Comeonin.Bcrypt.dummy_checkpw/2`, `Comeonin.Argon2.dummy_checkpw/2` and
  `Comeonin.Pbkdf2.dummy_checkpw/2` functions for *Bcrypt*, *Argon2* and *Pbkdf2*, respectively.
  """
  @spec dummy_checkpw() :: false
  def dummy_checkpw(), do: dummy_checkpw(@digestion)

  @doc """
  Same as `dummy_checkpw/0`, but uses the algorithm supplied as a parameter.

  Use `dummy_checkpw/0` convenience function to rely on configuration.
  """
  @spec dummy_checkpw(algorithm()) :: false
  def dummy_checkpw(:bcrypt), do: Comeonin.Bcrypt.dummy_checkpw()
  def dummy_checkpw(:argon2), do: Comeonin.Argon2.dummy_checkpw()
  def dummy_checkpw(:pbkdf2), do: Comeonin.Pbkdf2.dummy_checkpw()

  defp parse(otc) do
    lower_bound = String.length(@prefix)
    upper_bound = String.length(otc) - String.length(@postfix)

    String.slice(otc, lower_bound..upper_bound)
  end

  defp wrap(result), do: "#{@prefix}#{result}#{@postfix}"
end
