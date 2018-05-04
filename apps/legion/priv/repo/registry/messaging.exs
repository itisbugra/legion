# Script for populating messaging setting registers. You can run it as:
#
#.    mix run priv/repo/registry/messaging.exs
#
# Inside the script, you can read and write to the registry repo directly:
#
#.    Repo.insert!(%Registry{key: "Some.Module.key"})
#
# We use the following convention for naming keys:
#
#.    Messaging.Switching.Globals.some_key_about_anything
#
# If the key has a boolean value, we postfix the key with a "?".
#
#.    Messaging.Switching.Globals.am_i_hungry?
defmodule Legion.Repo.Registry.Messaging do
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

  def change do
    put_key "Messaging.Switching.Globals.is_apm_enabled?"
    put_key "Messaging.Switching.Globals.is_push_enabled?"
    put_key "Messaging.Switching.Globals.is_sms_enabled?"
    put_key "Messaging.Switching.Globals.is_mailing_enabled?"
    put_key "Messaging.Switching.Globals.is_platform_enabled?"
  end
end

Legion.Repo.Registry.Messaging.change()
