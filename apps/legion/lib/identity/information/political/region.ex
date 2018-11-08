defmodule Legion.Identity.Information.Political.Region do
  @moduledoc """
  Represents political regions of the world.
  """
  use Legion.Stereotype, :model

  @primary_key {:name, :string, autogenerate: false}

  schema "regions" do
    field(:code, :integer)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> add_error(:name, "cannot create region at runtime")
  end
end
