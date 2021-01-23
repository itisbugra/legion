defmodule Legion.Identity.Information.Political.Subregion do
  @moduledoc """
  Represents subparts of political regions.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Political.Region

  @primary_key {:name, :string, autogenerate: false}

  schema "subregions" do
    belongs_to :region, Region, foreign_key: :region_name, references: :name, type: :string
    field :code, :integer
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> add_error(:name, "cannot create region at runtime")
  end
end
