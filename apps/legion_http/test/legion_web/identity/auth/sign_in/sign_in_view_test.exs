defmodule Legion.HTTP.Identity.Auth.SignInViewTest do
  @moduledoc false
  use Legion.HTTP.ConnCase

  import Phoenix.View

  @target_view Legion.HTTP.Identity.Auth.SignInView

  test "contains error in render if user cannot be found" do
    result = render(@target_view, "error.json", error: :no_user_verify)

    assert match?(%{error: :no_user_verify, user_info: %{reason: _}}, result)
  end

  test "contains error in render if scheme is unsupported" do
    result = render(@target_view, "error.json", error: :unsupported_scheme)

    assert match?(%{error: :unsupported_scheme, user_info: %{reason: _}}, result)
  end

  test "contains error in render if password is wrong" do
    result = render(@target_view, "error.json", error: :wrong_password)

    assert result.error in [:no_user_verify, :wrong_password]
    assert match?(%{user_info: %{reason: _}}, result)
  end
end
