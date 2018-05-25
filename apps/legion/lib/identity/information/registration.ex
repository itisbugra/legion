defmodule Legion.Identity.Information.Registration do
  @moduledoc """
  Represents registrations of users.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Registration

  @type id :: integer()

  @typedoc """
  Indicates a `Registration` struct or a user identifier.

  Most of the time, the API calls regarding users will use this type.
  """
  @type user_or_id :: Registration.id() | Registration

  schema "users" do
    field :has_gps_telemetry_consent?, :boolean, default: false
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:has_gps_telemetry_consent?])
  end
end
