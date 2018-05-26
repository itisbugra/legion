defmodule Legion.Messaging.Switching.GlobalsTest do
  @moduledoc false
  use Legion.DataCase

  import Legion.Messaging.Switching.Globals

  alias Legion.Messaging.Message.Medium
  alias Legion.Messaging.Settings.RegistryEntry

  @available_pushes Medium.__enum_map__()

  setup do
    user = Factory.insert(:user)

    %{user: user}
  end

  describe "enable_medium/2" do
    for push <- @available_pushes do
      @push push

      test "enables #{Atom.to_string(@push)} medium", %{user: user} do
        assert enable_medium(user, @push) == :ok
      end
    end
  end

  describe "enable_≈_medium/1 et al." do
    test "enables apm medium", %{user: user} do
      assert enable_apm_medium(user) == :ok
    end

    test "enables push medium", %{user: user} do
      assert enable_push_medium(user) == :ok
    end

    test "enables mailing medium", %{user: user} do
      assert enable_mailing_medium(user) == :ok
    end

    test "enables sms medium", %{user: user} do
      assert enable_sms_medium(user) == :ok
    end

    test "enables platform medium", %{user: user} do
      assert enable_platform_medium(user) == :ok
    end
  end

  describe "disable_medium/2" do
    for push <- @available_pushes do
      @push push

      test "disables #{Atom.to_string(@push)} medium", %{user: user} do
        assert disable_medium(user, @push)
      end
    end
  end

  describe "disable_≈_medium/1 et al." do
    test "disables apm medium", %{user: user} do
      assert disable_apm_medium(user) == :ok
    end

    test "disables push medium", %{user: user} do
      assert disable_push_medium(user) == :ok
    end

    test "disables mailing medium", %{user: user} do
      assert disable_mailing_medium(user) == :ok
    end

    test "disables sms medium", %{user: user} do
      assert disable_sms_medium(user) == :ok
    end

    test "disables platform medium", %{user: user} do
      assert disable_platform_medium(user) == :ok
    end
  end

  describe "is_medium_enabled?/1" do
    for push <- @available_pushes  do
      @push push

      test "retrieves status for the #{Atom.to_string(@push)} medium" do
        assert is_medium_enabled?(@push)
      end
    end
  end

  describe "redirect_medium?/4" do
    test "redirects medium to another medium", %{user: user} do
      assert redirect_medium(user, :apm, :push) == :ok
      assert Repo.get_by!(RegistryEntry, key: "Messaging.Switching.Globals.apm_redirection")
    end

    test "does not redirect medium with negative duration", %{user: user} do
      assert redirect_medium(user, :apm, :push, for: -1) == {:error, :invalid_duration}
    end

    test "does not redirect medium with negative deferral", %{user: user} do
      assert redirect_medium(user, :apm, :push, after: -1) == {:error, :invalid_deferral}
    end
  end
end
