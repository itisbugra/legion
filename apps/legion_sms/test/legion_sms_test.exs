defmodule LegionSMSTest do
  use ExUnit.Case
  doctest LegionSMS

  test "greets the world" do
    assert LegionSMS.hello() == :world
  end
end
