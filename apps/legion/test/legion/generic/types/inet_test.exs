defmodule Legion.Types.INETTest do
  use Legion.DataCase

  alias Legion.Types.INET

  setup do
    {:ok, addr: %Postgrex.INET{address: {255, 255, 255, 0}}}
  end

  describe "casting" do
    test "with a native type", %{addr: addr} do
      {:ok, result} = INET.cast(addr)

      assert result == addr
    end

    test "with a valid binary to native type", %{addr: addr} do
      {:ok, result} = INET.cast("255.255.255.0")

      assert result == addr
    end

    test "returns error if given binary to cast is invalid", %{addr: _addr} do
      assert INET.cast("invalid_value") == :error
    end

    test "returns error if given parameter to cast is invalid", %{addr: _addr} do
      assert INET.cast(:invalid_param) == :error
    end
  end

  describe "loading" do
    test "with a native type", %{addr: addr} do
      {:ok, result} = INET.load(addr)

      assert result == addr
    end

    test "returns error if parameter is invalid", %{addr: _addr} do
      assert INET.load(:invalid_param) == :error
    end
  end

  describe "dumping" do
    test "with a native type", %{addr: addr} do
      {:ok, result} = INET.dump(addr)

      assert result == addr
    end

    test "returns error if parameter is invalid", %{addr: _addr} do
      assert INET.dump(:invalid_param) == :error
    end
  end

  describe "decoding" do
    test "a native type into binary", %{addr: addr} do
      assert INET.decode(addr) == "255.255.255.0"
    end

    test "returns error when address is invalid" do
      assert INET.decode(%Postgrex.INET{address: nil}) == :error
    end
  end

  describe "string extension" do
    test "converts native type to binary", %{addr: addr} do
      assert String.Chars.to_string(addr) == "255.255.255.0"
    end

    test "returns error when address is invalid" do
      assert INET.decode(%Postgrex.INET{address: nil}) == :error
    end
  end
end
