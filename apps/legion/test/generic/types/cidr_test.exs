defmodule Legion.Types.CIDRTest do
  use Legion.DataCase

  alias Legion.Types.CIDR

  setup do
    {:ok, addr: %Postgrex.CIDR{address: {192, 168, 0, 0}, netmask: 24}}
  end

  describe "casting" do
    test "with a native type", %{addr: addr} do
      assert CIDR.cast(addr) == {:ok, addr}
    end

    test "with a valid binary to native type", %{addr: addr} do
      assert CIDR.cast("192.168.0.0/24") == {:ok, addr}
    end

    test "returns error if given binary to cast is invalid", %{addr: _addr} do
      assert CIDR.cast("invalid_value") == :error
    end

    test "returns error if given parameter to cast is invalid", %{addr: _addr} do
      assert CIDR.cast(:invalid_param) == :error
    end
  end

  describe "loading" do
    test "with a native type", %{addr: addr} do
      assert CIDR.load(addr) == {:ok, addr}
    end

    test "returns error if parameter is invalid", %{addr: _addr} do
      assert CIDR.load(:invalid_param) == :error
    end
  end

  describe "dumping" do
    test "with a native type", %{addr: addr} do
      assert CIDR.dump(addr) == {:ok, addr}
    end

    test "returns error if parameter is invalid", %{addr: _addr} do
      assert CIDR.dump(:invalid_param) == :error
    end
  end

  describe "decoding" do
    test "a native type into binary", %{addr: addr} do
      assert CIDR.decode(addr) == "192.168.0.0/24"
    end

    test "returns error when address is invalid" do
      assert CIDR.decode(%Postgrex.CIDR{address: nil, netmask: 24}) == :error
    end

    test "returns error when netmask is invalid" do
      assert CIDR.decode(%Postgrex.CIDR{address: {192, 168, 0, 0}, netmask: nil}) == :error
    end
  end

  describe "string extension" do
    test "converts native type to binary", %{addr: addr} do
      assert String.Chars.to_string(addr) == "192.168.0.0/24"
    end

    test "returns error when address is invalid" do
      assert String.Chars.to_string(%Postgrex.CIDR{address: nil, netmask: 24}) == :error
    end

    test "returns error when netmask is invalid" do
      assert String.Chars.to_string(%Postgrex.CIDR{address: {192, 168, 0, 0}, netmask: nil}) ==
               :error
    end
  end
end
