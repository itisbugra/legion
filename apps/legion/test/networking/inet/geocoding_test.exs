defmodule Legion.Location.ReverseGeocodingTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Networking.INET.Geocoding

  @inet_addr {213, 194, 69, 204}

  @tag :external
  test "queries for the geocode by using inet addr" do
    unless match? {:ok, _}, Geocoding.trace(@inet_addr) do
      flunk "inet addr cannot be reverse geocoded, probably external service is down"
    end
  end
end