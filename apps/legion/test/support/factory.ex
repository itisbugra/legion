defmodule Legion.Factory do
  @moduledoc """
  Defines factory models to be used as a seeder in tests.
  """
  use ExMachina.Ecto, repo: Legion.Repo

  alias Legion.Identity.Auth.Concrete.Passkey
  alias Legion.Identity.Auth.TFA.OneTimeCode

  def user_factory do
    %Legion.Identity.Information.Registration{
      has_gps_telemetry_consent?: true,
    }
  end

  def passphrase_factory do
    passkey = Legion.Identity.Auth.Concrete.Passkey.generate()

    %Legion.Identity.Auth.Concrete.Passphrase{
      user: build(:user),
      passkey_digest: Passkey.hash(passkey),
      ip_addr: %Postgrex.INET{address: (1..4 |> Enum.map(&Enum.random(&1..255)) |> List.to_tuple())}
    }
  end

  def passphrase_invalidation_factory do
    %Legion.Identity.Auth.Concrete.Passphrase.Invalidation{
      source_passphrase: build(:passphrase),
      target_passphrase: build(:passphrase)
    }
  end

  def permission_factory do
    %Legion.Identity.Auth.AccessControl.Permission{
      controller_name: sequence(:controller_name, &"Elixir.#{&1}Controller"),
      controller_action: "create",
      type: "all"
    }
  end

  def activity_factory do
    %Legion.Identity.Auth.Concrete.Activity{
      passphrase: build(:passphrase),
      user_agent: sequence(:user_agent, &"#{&1}th user agent"),
      ip_addr: %Postgrex.INET{address: (1..4 |> Enum.map(&Enum.random(&1..255)) |> List.to_tuple())}
    }
  end

  def tfa_handle_factory do
    otc = OneTimeCode.generate()

    %Legion.Identity.Auth.Concrete.TFAHandle{
      user: build(:user),
      otc_digest: OneTimeCode.hash(otc),
      otc: otc,
      passphrase_id: nil
    }
  end
end
