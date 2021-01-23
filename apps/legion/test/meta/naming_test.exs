defmodule Legion.Meta.NamingTest do
  @moduledoc false
  use Legion.DataCase
  doctest Legion.Meta.Naming

  import Legion.Meta.Naming

  @uppercase "SomeFixture"
  @alien :inserted_at

  describe "delegated calls" do
    test "delegates humanize" do
      assert humanize(@alien) == "Inserted at"
    end

    test "delegates underscore" do
      assert underscore(@uppercase) == "some_fixture"
    end

    test "delegates unsuffix" do
      assert unsuffix("MyApp.UserView", "View") == "MyApp.User"
    end
  end
end
