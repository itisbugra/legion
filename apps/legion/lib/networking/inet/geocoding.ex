defmodule Legion.Networking.INET.Geocoding do
  @moduledoc """
  Reverse geocoding support for the INET addresses.
  """
  import NaiveDateTime, only: [utc_now: 0]

  alias Legion.Networking.INET
  alias Legion.Location.Geocode

  @doc """
  Traces an INET address using IP reverse geocoding service.
  """
  @spec trace(INET.t()) ::
          {:ok, Geocode.t()}
          | {:error, any}
  def trace(ip_addr) do
    case FreeGeoIP.Search.search(ip_addr) do
      {:ok, result} ->
        output = %Geocode{
          location: %Postgrex.Point{x: result["longitude"], y: result["latitude"]},
          country_name: result["country_name"],
          country_code: result["country_code"],
          metro_code: result["metro_code"],
          region_code: result["region_code"],
          region_name: result["region_name"],
          time_zone: result["time_zone"],
          zip_code: result["zip_code"],
          geocoder: FreeGeoIP,
          channel: :inet,
          timestamp: utc_now(),
          meta: %{ip_addr: ip_addr}
        }

        {:ok, output}

      {:error, %{reason: reason}} ->
        {:error, reason}
    end
  end
end
