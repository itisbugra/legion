defmodule Legion.Messaging.Settings.RegistryEntry do
  @moduledoc """
  Configures runtime configurable settings.
  """
  use Legion.Stereotype, :singleton

  alias Legion.Messaging.Settings.Register
  alias Legion.Identity.Information.Registration, as: User

  schema "messaging_settings_registry_entries" do
    belongs_to :register, Register, primary_key: true, foreign_key: :key, type: :string, references: :key
    field :value, :map
    belongs_to :authority, User
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  @spec changeset(RegistryEntry, map()) :: Ecto.Changeset.t
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :value, :authority_id])
    |> validate_required([:key, :value, :authority_id])
    |> foreign_key_constraint(:authority_id)
    |> foreign_key_constraint(:key)
  end
end
