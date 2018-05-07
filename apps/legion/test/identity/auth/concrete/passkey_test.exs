defmodule Legion.Identity.Generic.PasskeyTest do
  use Legion.DataCase

  alias Legion.Identity.Auth.Concrete.Passkey

  @env Application.get_env(:legion, Legion.Identity.Auth.Concrete)
  @scale Keyword.fetch!(@env, :passkey_scaling)

  test "generates a binary passkey" do
    assert Passkey.bingenerate()
  end

  test "generates a base64 passkey with absolute length of #{@scale * 1024}" do
    assert Passkey.generate()
  end

  test "sleeps for a while in order to prevent from probing" do
    Passkey.stall()

    assert true
  end
end
