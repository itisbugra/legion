defmodule Legion.HTTP.Identity.Auth.SignUp.RegistrationViewTest do
  @moduledoc false
  use Legion.HTTP.ConnCase, async: true

  import Phoenix.View

  @insecure_env Application.get_env(:legion, Legion.Identity.Auth.Insecure)
  @username_length Keyword.fetch!(@insecure_env, :username_length)

  @target_view Legion.HTTP.Identity.Auth.SignUp.RegistrationView

  setup do
    username = random_string(Enum.min(@username_length))

    %{registration: 
      %{username: username,
        user_id: Enum.random(1..5),
        inserted_at: NaiveDateTime.utc_now()}
    }
  end

  test "renders registration info with needed fields", params do
    result = render @target_view, "registration_info.json", params

    assert result.username == params.registration.username
    assert result.user_id == params.registration.user_id
    assert result.timestamp
    refute result.timestamp == params.registration.inserted_at
  end

  test "does not contain sensitive fields on output", params do
    result = render @target_view, "registration_info.json", params

    refute Map.has_key?(result, :password)
    refute Map.has_key?(result, :password_hash)
    refute Map.has_key?(result, :password_digest)
  end
end