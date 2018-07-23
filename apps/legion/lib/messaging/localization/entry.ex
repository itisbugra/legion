defmodule Legion.Messaging.Localization.Entry do
  @moduledoc """
  Represents a localization entry to make the template available in such language/region.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Registration, as: User
  alias Legion.Messaging.Templatization.Template
  alias Legion.Templating.Renderer.Engine

  schema "messaging_template_localization_entry" do
    belongs_to :user, User
    belongs_to :template, Template
    field :engine, Engine
    field :subject_template, :string
    field :body_template, :string
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :template_id, :engine, :subject_template,
                     :body_template])
    |> validate_required([:user_id, :template_id, :engine, :body_template])
    |> foreign_key_constraint(:user_id)
  end
end
