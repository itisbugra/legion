defmodule Legion.Identity.Information.Political.Country do
  @moduledoc """
  Represents countries in the world. This model is pregenerated during setup of the application.

  ## Schema fields

  - `:two_letter`: Two-letter code for identifying the country.
  - `:three_letter`: Variant for two-letter code for identifying the country, but in three letters.
  - `:iso_3166`: ISO-3166 code for the country.
  - `:region`: A reference to the region of the country.
  - `:subregion`: A reference to the subregion of the country.
  - `:intermediate_region`: A reference to the intermediate region of the country.
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

  @spec does_contain_point?(__MODULE__, Legion.Location.Coordinate.t()) :: boolean()
  def does_contain_point?(_country, _location) do
    true
  end
end