defmodule Legion.Templating.Renderer do
  @moduledoc """
  Provides utility functions and a behaviour for injecting external
  templating engines.
  """
  import EctoEnum, only: [defenum: 3]

  @doc """
  Renders a string from given template and parameters.
  """
  @callback render(template :: String.t(), params :: any()) ::
              {:ok, String.t()} | {:error, atom()}

  @doc """
  Derives parameters from given template, which will create a strict validation schema.
  """
  @callback derive_params(template :: String.t()) ::
              {:ok, [String.t()]} | {:error, atom()}

  @typedoc """
  Type specification for engine-defining atoms.
  """
  @type engine :: :liquid

  defenum(Engine, :template_rendering_engine, [:liquid])

  @spec provide_implementation(engine()) :: module()
  def provide_implementation(:liquid),
    do: Legion.Templating.Engines.Liquid
end
