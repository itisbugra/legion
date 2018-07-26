defmodule Legion.HTTP.Utils.DateConversion do
  def put_date(date = %NaiveDateTime{}),
    do: NaiveDateTime.to_iso8601(date)
end
