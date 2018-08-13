defmodule Legion.Identity.Information.Political.Country do
  @moduledoc """
  Represents countries in the world.

  ## Schema fields
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Political.{Region, Subregion, IntermediateRegion}

  @primary_key {:name, :string, autogenerate: false}

  schema "countries" do
    field :two_letter, :string
    field :three_letter, :string
    field :iso_3166, :string
    belongs_to :region, Region, foreign_key: :region_name, references: :name, type: :string
    belongs_to :subregion, Subregion, foreign_key: :subregion_name, references: :name, type: :string
    belongs_to :intermediate_region, IntermediateRegion, foreign_key: :intermediate_region_name, references: :name, type: :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> add_error(:name, "cannot create region at runtime")
  end
end