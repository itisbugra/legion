defmodule Legion.Internationalization.LocaleTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Internationalization.Locale

  test "changeset cannot be valid no matter what" do
    refute Locale.changeset(%Locale{},
                            %{rfc1766: "en-us",
                              language: "en",
                              abbreviation: "tr",
                              variant: nil}).valid?
  end

  test "changet cannot be valid with default struct either" do
    refute Locale.changeset(%Locale{}).valid?
  end
end
