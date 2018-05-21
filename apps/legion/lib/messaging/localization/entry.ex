defmodule Legion.Messaging.Localization.Entry do
  @moduledoc """
  Represents a localization entry to make the template available in such language/region.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Messaging.Templatization.Template
  alias Legion.Templating.{Renderer, Renderer.Engine}

  schema "messaging_template_localization_entry" do
    belongs_to :user, User
    belongs_to :template, Template
    field :engine, Engine
    field :subject_template, :string
    field :subject_params, {:array, :string}, default: []
    field :body_template, :string
    field :body_params, {:array, :string}, default: []
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :template_id, :engine, :subject_template,
                     :body_template])
    |> validate_required([:user_id, :template_id, :engine, :body_template])
    |> determine_params()
    |> foreign_key_constraint(:user_id)
  end

  defp determine_params(changeset) do
    if changeset.valid? do
      changeset
      |> determine_params(:subject)
      |> determine_params(:body)
    else
      changeset
    end
  end

  defp determine_params(changeset, field) do
    template = get_field(changeset, :"#{Atom.to_string(field)}_template")
    engine = get_field(changeset, :engine)
    impl = Renderer.provide_implementation(engine)

    case impl.derive_params(template) do
      {:ok, params} ->
        put_change(changeset, :"#{Atom.to_string(field)}_params", params)
      {:error, _} ->
        add_error(changeset, :"#{Atom.to_string(field)}_template", "could not derive params from template")
    end
  end
end
