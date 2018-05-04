defmodule Legion.Messaging.Settings.Register do
  @moduledoc """
  Defines a settings register.
  """
  use Legion.Stereotype, :model

  @primary_key false

  schema "messaging_settings_registers" do
    field :key, :string, primary_key: true, source: "key"
  end

  def changeset(struct, _params) do
    struct
    |> cast(%{}, [])
    |> add_error(:key, "cannot add register at runtime")
  end
end
