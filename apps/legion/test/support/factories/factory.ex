defmodule Legion.Factory do
  @moduledoc """
  Defines factory models to be used as a seeder in tests.
  """
  use ExMachina.Ecto, repo: Legion.Repo
  use Legion.TemplateFactory
  use Legion.Identity.Information.AddressBook.Factory
  use Legion.Identity.Information.Political.Factory
  use Legion.Identity.Information.Telephony.Factory

  alias Legion.Identity.Auth.Concrete.Passkey
  alias Legion.Identity.Auth.TFA.OneTimeCode

  @insecure_env Application.get_env(:legion, Legion.Identity.Auth.Insecure)
  @password_digestion Keyword.fetch!(@insecure_env, :password_digestion)

  def user_factory do
    %Legion.Identity.Information.Registration{
      has_gps_telemetry_consent?: true
    }
  end

  def passphrase_factory do
    passkey = Legion.Identity.Auth.Concrete.Passkey.generate()

    %Legion.Identity.Auth.Concrete.Passphrase{
      user: build(:user),
      passkey: passkey,
      passkey_digest: Passkey.hash(passkey),
      ip_addr: %Postgrex.INET{address: 1..4 |> Enum.map(&Enum.random(&1..255)) |> List.to_tuple()}
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
      ip_addr: %Postgrex.INET{address: 1..4 |> Enum.map(&Enum.random(&1..255)) |> List.to_tuple()}
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

  def messaging_settings_register_factory do
    %Legion.Messaging.Settings.Register{
      key: sequence(:messaging_setting_register_key, &"Some.key#{&1}")
    }
  end

  def messaging_settings_registry_entry_factory do
    %Legion.Messaging.Settings.RegistryEntry{
      key: build(:messaging_settings_register),
      authority: build(:user),
      value: %{"field" => "value"}
    }
  end

  def pair_factory do
    password = sequence(:pair_password_key, &"some_password#{&1}")
    password_hash = Legion.Identity.Auth.Algorithm.Keccak.hash(password)

    %Legion.Identity.Auth.Insecure.Pair{
      user: build(:user),
      username: sequence(:pair_username_key, &"some_username#{&1}"),
      password_hash: password_hash,
      password_digest: Legion.Identity.Auth.Insecure.Pair.hashpwsalt(password_hash),
      digestion_algorithm: @password_digestion
    }
  end
end
