defmodule Legion.Identity.Information.Registration do
  @moduledoc """
  Represents registrations of users.
  """
  use Legion.Stereotype, :model

  schema "users" do
    field :has_gps_telemetry_consent?, :boolean, default: false
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:has_gps_telemetry_consent?])
  end
end
