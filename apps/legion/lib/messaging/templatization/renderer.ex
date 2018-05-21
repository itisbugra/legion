defmodule Legion.Messaging.Templatization.Renderer do
  @moduledoc """
  Provides business logic to RenderingResult parametric message templates.
  """
  alias Legion.Messaging.Templatization.{Template, RenderingResult}
  alias Legion.Templating.Renderer

  @doc """
  Generates a message with given template and template parameters.
  """
  @spec generate_message(Template, map(), map()) ::
    {:ok, RenderingResult.t} |
    {:error, {:param_is_missing, atom()}}
  def generate_message(template, subject_params, body_params) do
    with {:ok, subject} <- eval_template(template.subject_template,
                                         template.engine,
                                         template.subject_params,
                                         subject_params),
         {:ok, body} <- eval_template(template.body_template,
                                      template.engine,
                                      template.body_params,
                                      body_params)
    do
      {:ok, %RenderingResult{subject: subject, body: body}}
    else
      {:error, desc} ->
        {:error, desc}
    end
  end

  defp eval_template(template, engine, available_params, supplied_params) do
    with :ok <- check_params(available_params, supplied_params),
         params <- scrub_params(available_params, supplied_params),
         engine <- Renderer.provide_implementation(engine)
    do
      engine.render(template, params)
    else
      {:error, desc} ->
        {:error, desc}
    end
  end

  defp check_params(required_params, candidates) do
    supplied_params = Map.keys(candidates)
    filtered_params = Enum.filter(required_params, fn x -> not Enum.member?(supplied_params, x) end)

    if Enum.empty?(filtered_params) do
      :ok
    else
      {:error, {:param_is_missing, List.first(filtered_params)}}
    end
  end

  defp scrub_params(availables, candidates) do
    keys = Enum.filter(Map.keys(candidates), fn x -> not Enum.member?(availables, x) end)

    Map.drop(candidates, keys)
  end
end
