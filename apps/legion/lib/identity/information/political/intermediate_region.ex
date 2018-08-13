defmodule Legion.Identity.Information.Political.IntermediateRegion do
  @moduledoc """
  Represents groups of countries found in specific subregions.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Political.Subregion

  @primary_key {:name, :string, autogenerate: false}

  schema "intermediate_regions" do
    belongs_to :subregion, Subregion, foreign_key: :subregion_name, references: :name, type: :string
    field :code, :integer
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> add_error(:name, "cannot create region at runtime")
  end
end