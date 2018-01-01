defmodule Legion.Types.PointTest do
  use Legion.DataCase

  alias Legion.Types.Point

  setup do
    {:ok, point: %Postgrex.Point{x: 5.00, y: 5.00}}
  end

  describe "casting" do
    test "with a native type", %{point: point} do
      {:ok, result} = Point.cast(point)

      assert result == point
    end

    test "returns error if parameter is invalid", %{point: _point} do
      assert Point.cast(:invalid_param) == :error
    end
  end

  describe "loading" do
    test "with a native type", %{point: point} do
      {:ok, result} = Point.load(point)

      assert result == point
    end

    test "returns error if parameter is invalid", %{point: _point} do
      assert Point.load(:invalid_param) == :error
    end
  end

  describe "dumping" do
    test "with a native type", %{point: point} do
      {:ok, result} = Point.dump(point)

      assert result == point
    end

    test "returns error if parameter is invalid", %{point: _point} do
      assert Point.dump(:invalid_param) == :error
    end
  end

  describe "decoding" do
    test "with a native type", %{point: point} do
      assert Point.decode(point) == "(#{point.x}, #{point.y})"
    end

    test "returns error if parameter is invalid", %{point: _point} do
      assert Point.decode(:invalid_param) == :error
    end
  end

  describe "string extension" do
    test "with a native type", %{point: point} do
      assert String.Chars.to_string(point) == "(#{point.x}, #{point.y})"
    end
  end
end
