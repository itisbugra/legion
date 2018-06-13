defmodule Mix.Tasks.Legion.Reg.Messaging do
  @moduledoc """
  Synchronizes messaging subsystem registers, such as global switches
  and redirection keys.

  Redirection keys are formatted in
  `"Messaging.Switching.Globals.{medium}_redirection"`, whereas
  switching keys are formatted in
  `"Messaging.Switching.Globals.is_{medium}_enabled?"` pattern.
  """
  use Legion.RegistryDirectory.Synchronization, site: Legion.Messaging.Settings, repo: Legion.Repo

  @shortdoc "Synchronizes messaging subsystem registers"

  require Logger

  alias Legion.Repo
  alias Legion.Messaging.Settings.Register

  Logger.configure level: :info

  def register(key) do
    register = Repo.insert!(%Register{key: key})

    Logger.info "added register #{register.key}"
  rescue
    Ecto.ConstraintError ->
      Logger.warn "cannot add register #{key}, it is already added"
  end

  def sync do
    register "Messaging.Switching.Globals.is_apm_enabled?"
    register "Messaging.Switching.Globals.is_push_enabled?"
    register "Messaging.Switching.Globals.is_sms_enabled?"
    register "Messaging.Switching.Globals.is_mailing_enabled?"
    register "Messaging.Switching.Globals.is_platform_enabled?"
    register "Messaging.Switching.Globals.apm_redirection"
    register "Messaging.Switching.Globals.push_redirection"
    register "Messaging.Switching.Globals.sms_redirection"
    register "Messaging.Switching.Globals.mailing_redirection"
    register "Messaging.Switching.Globals.platform_redirection"
  end
end
