defmodule Legion.Location.Geocode do
  @moduledoc """
  Represents information about a location geocode. A geocode is a locational 
  estimation of a location identified by a connection artifact or such.
  The data can be mostly used to analytic purposes, rather than transactional
  operations.
  """
  @enforce_keys ~w(location country_name country_code metro_code region_code region_name time_zone geocoder channel timestamp)a

  defstruct [
    :location,
    :country_name,
    :country_code,
    :metro_code,
    :region_code,
    :region_name,
    :time_zone,
    :zip_code,
    :geocoder,
    :channel,
    :meta,
    :timestamp
  ]

  alias Legion.Location.Coordinate

  @typedoc """
  Shows the method of the retrieval of geocode data.
  """
  @type channel() :: :inet | :gps

  @typedoc """
  Represents information about a location.

  ## Fields

  - `:location`: Roughly estimated location for the geocode.
  - `:country_name`: Name of the country, e.g. `"Turkey"`.
  - `:country_code`: Code of the country, e.g. `"TR"`.
  - `:metro_code`: Metro code.
  - `:region_code`: Code of the region, e.g. `"34"`.
  - `:region_name`: Name of the region, e.g. `"Istanbul"`.
  - `:time_zone`: Time zone of the location, e.g. `"Europe/Istanbul"`.
  - `:zip_code`: Zip code of the location, e.g. `"34134"`.
  - `:geocoder`: The toolchain used to create the geocode.
  - `:channel`: The channel used as a metaartifact of the geocode.
  - `:meta`: Additional metadata given by the geocoder.
  - `:timestamp`: The time of the geocoding lookup.
  """
  @type t() :: %__MODULE__{
          location: Coordinate.t(),
          country_name: binary(),
          country_code: binary(),
          metro_code: binary(),
          region_code: binary(),
          region_name: binary(),
          time_zone: binary(),
          zip_code: binary(),
          geocoder: atom(),
          channel: channel(),
          meta: map(),
          timestamp: NaiveDateTime.t()
        }

  @doc """
  Returns a new empty geocode.

  ## Examples

      iex> Legion.Location.Geocode.new()
      %Legion.Location.Geocode{location: nil, country_name: nil, country_code: nil, metro_code: nil, region_code: nil, region_name: nil, time_zone: nil, zip_code: nil, geocoder: nil, channel: nil, meta: %{}, timestamp: nil}
  """
  def new,
    do: %Legion.Location.Geocode{
      location: nil,
      country_name: nil,
      country_code: nil,
      metro_code: nil,
      region_code: nil,
      region_name: nil,
      time_zone: nil,
      zip_code: nil,
      geocoder: nil,
      channel: nil,
      meta: %{},
      timestamp: nil
    }
end
