defmodule Legion.HTTP.Utils.DateConversion do
  @moduledoc """
  Converts native timestamp units to endpoint-to-endpoint compatible format.
  """
  def put_date(date = %NaiveDateTime{}),
    do: NaiveDateTime.to_iso8601(date)
end
