defmodule Legion.Identity.Information.Nationality do
  @moduledoc """
  ISO-3116 standardized nationalities for the users of the application.
  """
  use Legion.Stereotype, :model

  @primary_key {:abbreviation, :string, autogenerate: false}

  schema "nationalities" do
    field :country_name, :string
    field :preferred_demonym, :string
    field :second_demonym, :string
    field :third_demonym, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> add_error(:country_name, "cannot create nationality at runtime")
  end
end
