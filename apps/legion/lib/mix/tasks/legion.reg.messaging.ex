if Code.ensure_loaded?(Legion.Messaging.Settings.Register) do
  defmodule Mix.Tasks.Legion.Reg.Messaging do
    require Logger

    import Mix.Ecto

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
      {:ok, pid, _apps} = ensure_started(Repo, [])
      sandbox? = Repo.config[:pool] == Ecto.Adapters.SQL.Sandbox

      if sandbox? do
        Ecto.Adapters.SQL.Sandbox.checkin(Repo)
        Ecto.Adapters.SQL.Sandbox.checkout(Repo, sandbox: false)
      end

      Logger.info fn ->
        "== Adding messaging registers"
      end

      put_key "Messaging.Switching.Globals.is_apm_enabled?"
      put_key "Messaging.Switching.Globals.is_push_enabled?"
      put_key "Messaging.Switching.Globals.is_sms_enabled?"
      put_key "Messaging.Switching.Globals.is_mailing_enabled?"
      put_key "Messaging.Switching.Globals.is_platform_enabled?"
      put_key "Messaging.Switching.Globals.apm_redirection"
      put_key "Messaging.Switching.Globals.push_redirection"
      put_key "Messaging.Switching.Globals.sms_redirection"
      put_key "Messaging.Switching.Globals.mailing_redirection"
      put_key "Messaging.Switching.Globals.platform_redirection"

      sandbox? && Ecto.Adapters.SQL.Sandbox.checkin(Repo)

      pid && Repo.stop(pid)

      Logger.info fn ->
        "== Finished migrating messaging registers"
      end
    end
  end
end
