defmodule Legion.Identity.Generic.PasskeyTest do
  use Legion.DataCase

  alias Legion.Identity.Auth.Concrete.Passkey

  @env Application.get_env(:legion, Legion.Identity.Auth.Concrete)
  @scale Keyword.fetch!(@env, :passkey_scaling)

  test "generates a binary passkey" do
    assert Passkey.bingenerate()
  end

  test "generates a base64 passkey with absolute length of #{@scale * 22}" do
    passkey = Passkey.generate()

    assert passkey
    assert String.length(passkey) == @scale * 22
  end
end
