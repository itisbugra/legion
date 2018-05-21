defmodule Legion.Templating.Engines.Liquid do
  @moduledoc """
  Implements a templating engine using *Liquid*.
  """
  use Legion.Templating.Renderer.EngineStereotype

  alias Legion.Templating.Engines.Liquid.NodeList

  @doc """
  Renders a string from given template and parameters using *Liquid*
  templating engine.
  """
  @impl Legion.Templating.Renderer
  @spec render(template :: String.t, params :: any()) ::
    {:ok, String.t} |
    {:error, atom()}
  def render(template, params) do
    template = Liquid.Template.parse(template)

    case Liquid.Template.render(template, params) do
      {:ok, render_result, _} ->
        {:ok, render_result}
      any ->
        any
    end
  end

  @doc """
  Derives the parameters from given template using *Liquid* parser.
  """
  @impl Legion.Templating.Renderer
  @spec derive_params(template :: String.t) ::
    {:ok, [String.t]} | {:error, atom()}
  def derive_params(template) do
    params =
      template
      |> Liquid.Template.parse()
      |> NodeList.trace()

    {:ok, params}
  end
end

defmodule Legion.Templating.Engines.Liquid.NodeList do
  def trace(binary) when is_binary(binary), do: []
  def trace(list) when is_list(list) do
    list
    |> Enum.filter(&is_map/1)
    |> Enum.map(&trace/1)
    |> List.flatten()
    |> Enum.uniq()
  end
  def trace(%Liquid.Template{} = template), do: trace(template.root)
  def trace(%Liquid.Block{} = block) do
    if not block.blank do
      condition = trace(block.condition)
      elselist = Enum.map(block.elselist, &trace/1)
      iterator = trace(block.iterator)
      item = get_item(block.iterator)
      nodelist = trace(block.nodelist) |> Enum.reject(fn x -> Enum.member?(item, x) end)

      condition ++ elselist ++ nodelist ++ iterator
    else
      []
    end
  end
  def trace(%Liquid.ForElse.Iterator{} = iterator) do
    [iterator.name]
  end
  def trace(%Liquid.Condition{} = condition) do
    left_param = if left = Map.get(condition, :left), do: Map.get(left, :name)

    cond do
      child_condition = Map.get(condition, :child_condition) ->
        [left_param | trace(child_condition)]
      left_param ->
        [left_param]
      true ->
        []
    end
  end
  def trace(%Liquid.Variable{} = variable) do
    if variable.literal do
      []
    else
      [variable.name]
    end
  end
  def trace(nil), do: []

  defp get_item(%Liquid.ForElse.Iterator{} = iterator) do
    [iterator.item]
  end
  defp get_item([]), do: []
end
