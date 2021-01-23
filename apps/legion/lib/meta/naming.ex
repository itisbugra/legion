defmodule Legion.Meta.Naming do
  @moduledoc """
  Functions for dealing with Elixir naming conventions & module syntax.

  **This module uses `Phoenix.Naming` functions.**
  """
  alias Phoenix.Naming

  @doc """
  Converts String to camel case.

  Takes an optional `:lower` option to return `lowerCamelCase`.

  In addition to the implementation of `Phoenix.Naming`, this function
  also accepts `atom()` inputs.

      iex> Legion.Meta.Naming.camelize("some_fixture")
      "SomeFixture"

      iex> Legion.Meta.Naming.camelize(:some_fixture)
      "SomeFixture"

      iex> Legion.Meta.Naming.camelize("SomeFixture")
      "SomeFixture"

      iex> Legion.Meta.Naming.camelize(:"SomeFixture")
      "SomeFixture"

      iex> Legion.Meta.Naming.camelize("some_fixture", :lower)
      "someFixture"

      iex> Legion.Meta.Naming.camelize(:some_fixture, :lower)
      "someFixture"

      iex> Legion.Meta.Naming.camelize(:"SomeFixture", :lower)
      "someFixture"
  """
  @spec camelize(atom() | binary()) :: 
    binary() |
    atom() |
    nil
  def camelize(value) when is_atom(value) do
    value
    |> Atom.to_string()
    |> Naming.camelize()
  end
  def camelize(value) when is_binary(value) do
    Naming.camelize(value)
  end

  def camelize(value, :lower) when is_atom(value) do
    value
    |> Atom.to_string()
    |> Naming.camelize(:lower)
  end
  def camelize(value, :lower) when is_binary(value) do
    Naming.camelize(value, :lower)
  end

  defdelegate humanize(atom), to: Naming
  defdelegate underscore(value), to: Naming
  defdelegate unsuffix(value, suffix), to: Naming
end