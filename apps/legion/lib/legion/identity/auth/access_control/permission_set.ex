defmodule Legion.Identity.Auth.AccessControl.PermissionSet do
  @moduledoc """
  Contains a group of permissions to enhance ease of usage.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Registration

  @env Application.get_env(:legion, Legion.Identity.Auth.AccessControl)
  @name_length Keyword.fetch!(@env, :permission_set_name_length)
  @description_length Keyword.fetch!(@env, :permission_set_description_length)

  schema "permission_sets" do
    field :name
    field :description
    belongs_to :user, Registration
  end

  def changeset(struct, params \\ %{}) do
    # FIXME: Proposal made by Chatatata, https://groups.google.com/forum/#!topic/elixir-ecto/GDTOHOiJ6qc.
    struct
    |> cast(params, [:name, :description, :user_id])
    |> validate_required([:name, :description, :user_id])
    |> validate_length(:name, min: Enum.min(@name_length), max: Enum.max(@name_length))
    |> validate_length(:description, min: Enum.min(@description_length), max: Enum.max(@description_length))
    |> foreign_key_constraint(:user_id)
  end
end
