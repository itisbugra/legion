defmodule Legion.Internationalization.Locale do
  @moduledoc """
  Represents a locale, containing a language and its variant.

  This is a registry-only module, it is not available to be mutated at the runtime.
  """
  use Legion.Stereotype, :model

  @primary_key {:rfc1766, :string, autogenerate: false}

  schema "locales" do
    field :language
    field :abbreviation
    field :variant
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> add_error(:language, "cannot create locale at runtime")
  end
end
