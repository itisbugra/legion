defmodule Legion.Identity.Auth.Abstract.TokenTest do
  @moduledoc false
  use Legion.DataCase

  import Legion.Identity.Auth.Abstract.Token

  setup do
    user = Factory.insert(:user)
    valid_passphrase = Factory.insert(:passphrase, user: user)

    %{user: user, valid_passphrase: valid_passphrase}
  end

  test "issues token with given user and passphrase", %{user: user, valid_passphrase: passphrase} do
    result = issue_token(user.id, passphrase.id)

    str = elem(result, 1)

    assert match?({:ok, _str}, result)
    assert str.header_value
    assert str.jwk
    assert str.jws
    assert str.expires_after
  end
end
