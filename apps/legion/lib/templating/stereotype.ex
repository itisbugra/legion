defmodule Legion.Templating.Renderer.EngineStereotype do
  @moduledoc """
  Provides stereotype for modules implementing templating engines.

  ## Example

      defmodule Legion.Templating.Engines.SomeEngine do
        use Legion.Templating.Renderer.EngineStereotype

        @impl Legion.Templating.Renderer
        @spec render(template :: String.t, params :: any()) ::
          {:ok, String.t} |
          {:error, atom()}
        def render(template, params) do
          {:ok, "rendered string"}
        end
      end
  """

  @doc false
  defmacro __using__(_opts) do
    quote do
      alias Legion.Templating.Renderer

      @behaviour Renderer

      def render(template, params), do: nil

      defoverridable Renderer
    end
  end
end
