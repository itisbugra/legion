defmodule Legion.Identity.Auth.TFA.OneTimeCodeTest do
  @moduledoc false
  use Legion.DataCase

  import Legion.Identity.Auth.TFA.OneTimeCode

  @env Application.get_env(:legion, Legion.Identity.Auth.OTC)
  @prefix Keyword.fetch!(@env, :prefix)
  @postfix Keyword.fetch!(@env, :postfix)
  @length Keyword.fetch!(@env, :length)

  describe "generate/1" do
    test "generates an integer otc" do
      val = generate(:integer)

      assert String.length(val) == String.length(@prefix) + String.length(@postfix) + @length
      assert val =~ Regex.compile!("#{@prefix}[0-9]{#{@length}}#{@postfix}")
    end

    test "generates an alphanumeric otc" do
      val = generate(:alphanumeric)

      assert String.length(val) == @length
    end
  end

  describe "generate/0" do
    test "generates an otc" do
      assert generate()
    end
  end

  describe "hash/1" do
    test "hashes given otc" do
      assert hash(generate(:integer))
    end
  end

  describe "stall/0" do
    test "sleeps for a while" do
      stall()
    end
  end
end
