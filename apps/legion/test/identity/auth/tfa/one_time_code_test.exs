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

  describe "hashpwsalt/1" do
    test "hashes given otc" do
      assert hashpwsalt(generate(:integer))
    end
  end

  describe "hashpwsalt/2" do
    test "hashes given otc with bcrypt" do
      assert hashpwsalt(generate(:integer), :bcrypt) =~ ~r(\$2b\$12\$)
    end

    test "hashes given otc with argon2" do
      assert hashpwsalt(generate(:integer), :argon2) =~ ~r(\$argon2i\$)
    end

    test "hashes given otc with pbkdf2" do
      assert hashpwsalt(generate(:integer), :pbkdf2) =~ ~r(\$pbkdf2-sha512\$)
    end
  end

  describe "checkpw/2" do
    test "validates given hash" do
      otc = generate(:integer)
      hash = hashpwsalt(otc)
      check = checkpw(otc, hash)

      assert otc
      assert hash
      refute otc == hash
      assert check
    end
  end

  describe "checkpw/3" do
    test "validates given hash with bcrypt" do
      otc = generate(:integer)
      hash = hashpwsalt(otc, :bcrypt)
      check = checkpw(otc, hash, :bcrypt)

      assert otc
      assert hash
      refute otc == hash
      assert check
    end

    test "validates given hash pbkdf2" do
      otc = generate(:integer)
      hash = hashpwsalt(otc, :pbkdf2)
      check = checkpw(otc, hash, :pbkdf2)

      assert otc
      assert hash
      refute otc == hash
      assert check
    end

    test "validates given hash argon2" do
      otc = generate(:integer)
      hash = hashpwsalt(otc, :argon2)
      check = checkpw(otc, hash, :argon2)

      assert otc
      assert hash
      refute otc == hash
      assert check
    end
  end

  describe "dummy_checkpw/0" do
    test "sleeps for a while" do
      dummy_checkpw()
    end
  end

  describe "dummy_checkpw/1" do
    test "sleeps for a while for argon2" do
      dummy_checkpw(:argon2)
    end

    test "sleeps for a while for bcrypt" do
      dummy_checkpw(:bcrypt)
    end

    test "sleeps for a while for pbkdf2" do
      dummy_checkpw(:pbkdf2)
    end
  end
end
