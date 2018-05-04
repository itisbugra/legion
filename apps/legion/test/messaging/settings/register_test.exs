defmodule Legion.Messaging.Settings.RegisterTest do
  @moduledoc false
  use Legion.DataCase

  alias Legion.Messaging.Settings.Register

  test "changeset is always invalid" do
    changeset = Register.changeset(%Register{}, %{key: "Some.key"})

    refute changeset.valid?
  end
end
