defmodule Legion.Identity.Information.Registration do
  @moduledoc """
  Represents registrations of users.
  """
  use Legion.Stereotype, :model

  alias Legion.Identity.Information.Registration
  alias Legion.Identity.Auth.Insecure.Pair
  alias Legion.Internationalization.Locale

  @typedoc """
  The type of the identifier to uniquely reference the users is
  managed by integer identifiers.
  """
  @type id :: integer()

  @typedoc """
  The type of the name of the user.
  """
  @type username :: String.t()

  @typedoc """
  Indicates a `Registration` struct or a user identifier.

  Most of the time, the API calls regarding users will use this type.
  """
  @type user_or_id :: Registration.id() | Registration

  schema "users" do
    field :has_gps_telemetry_consent?, :boolean, default: false
    belongs_to :locale, Locale, defaults: "en-us", foreign_key: :locale_rfc1766, references: :rfc1766, type: :binary
    field :inserted_at, :naive_datetime, read_after_writes: true
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:has_gps_telemetry_consent?])
  end
end
