defmodule Mix.Tasks.Legion.Reg.Messaging do
  require Logger

  alias Legion.Repo
  alias Legion.Messaging.Settings.Register

  Logger.configure level: :info

  defmacrop put_key(key) do
    quote do
      try do
        register = Repo.insert!(%Register{key: unquote(key)})

        Logger.info fn ->
          "added register #{register.key}"
        end
      rescue
        Ecto.ConstraintError ->
          Logger.warn fn ->
            "cannot add register #{unquote(key)}, it is already added"
          end
      end
    end
  end

  def run(_args) do
    put_key "Messaging.Switching.Globals.is_apm_enabled?"
    put_key "Messaging.Switching.Globals.is_push_enabled?"
    put_key "Messaging.Switching.Globals.is_sms_enabled?"
    put_key "Messaging.Switching.Globals.is_mailing_enabled?"
    put_key "Messaging.Switching.Globals.is_platform_enabled?"
  end
end
