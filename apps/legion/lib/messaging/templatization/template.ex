defmodule Legion.Messaging.Templatization.Template do
  @moduledoc """
  Provides templatization for sending parametric messages to the platform users.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Messaging.Templatization.Render
  alias __MODULE__, as: Template

  @env Application.get_env(:legion, Legion.Messaging.Templatization)
  @name_len Keyword.fetch!(@env, :template_name_length)

  schema "messaging_templates" do
    belongs_to :user, User
    field :name, :string
    field :subject_template, :string
    field :subject_params, {:array, :string}, default: []
    field :body_template, :string
    field :body_params, {:array, :string}, default: []
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  @doc """
  Generates a message with given template and template parameters.
  """
  @spec generate_message(Template, map(), map()) :: 
    {:ok, Render.t} |
    {:error, {:param_is_missing, :subject | :body, atom()}}
  def generate_message(template, subject_params, body_params) do
    with {:ok, subject} <- eval_template(template.subject_template, template.subject_params, subject_params),
         {:ok, body} <- eval_template(template.body_template, template.body_params, body_params) do
      {:ok, %Render{subject: subject, body: body}}
    else
      {:error, desc} ->
        {:error, desc}
    end
  end

  defp eval_template(template, available_params, supplied_params) do
    with :ok <- check_params(available_params, supplied_params),
         params <- scrub_params(available_params, supplied_params)
    do
      {:ok, Liquid.Template.render(template, params)}
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
    available_params = Enum.map(availables, fn x -> Atom.to_string(x) end)

    Enum.filter(candidates, fn x -> Enum.member?(available_params, x) end)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :name, :subject_template, :subject_params, 
                     :body_template, :body_params])
    |> validate_required([:user_id, :name, :subject_template, :body_template])
    |> validate_length(:name, min: Enum.min(@name_len), max: Enum.max(@name_len))
    |> foreign_key_constraint(:user_id)
  end
end
