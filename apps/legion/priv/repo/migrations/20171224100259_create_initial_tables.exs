defmodule Legion.Repo.Migrations.CreateInitialTables do
  use Ecto.Migration

  @env Application.get_env(:legion, Legion.Identity.Auth.Concrete.TFA)
  @allowed_otc_attempts Keyword.fetch!(@env, :allowed_attempts)

  def change do
    case direction() do
      :up ->
        Legion.Identity.Auth.AccessControl.ControllerAction.create_type()
        Legion.Messaging.Message.Medium.create_type()
        Legion.Templating.Renderer.Engine.create_type()
        Legion.Identity.Auth.Algorithm.Digestion.create_type()
        Legion.Identity.Auth.Concrete.Scheme.create_type()
      :down ->
        Legion.Identity.Auth.AccessControl.ControllerAction.drop_type()
        Legion.Messaging.Message.Medium.drop_type()
        Legion.Templating.Renderer.Engine.drop_type()
        Legion.Identity.Auth.Algorithm.Digestion.drop_type()
        Legion.Identity.Auth.Concrete.Scheme.drop_type()
    end

    create table(:locales, primary_key: false) do
      add :rfc1766, :text, primary_key: true, default: "en-us"
      add :language, :text
      add :abbreviation, :text
      add :variant, :text
    end

    create table(:users) do
      add :has_gps_telemetry_consent?, :boolean, default: false
      add :locale_rfc1766, references(:locales, on_delete: :restrict, on_update: :update_all, column: :rfc1766, type: :text), default: "en-us", null: false
      add :authentication_scheme, :authentication_scheme, null: false
      add :inserted_at, :naive_datetime, default: fragment("now()::timestamp"), null: false
    end

    create table(:permissions) do
      add :controller_name, :text, null: false
      add :controller_action, :controller_action, null: false
      add :type, :text, null: false
    end

    create unique_index(:permissions, [:controller_name, :controller_action, :type])
    create index(:permissions, [:controller_name, :controller_action])

    create table(:permission_sets) do
      add :name, :text, null: false
      add :description, :text, null: false
      add :user_id, references(:users, on_delete: :restrict, on_update: :update_all), null: false
      add :inserted_at, :naive_datetime, default: fragment("now()::timestamp"), null: false
    end

    create unique_index(:permission_sets, [:name])

    create table(:permission_set_permissions) do
      add :permission_set_id, references(:permission_sets, on_delete: :restrict, on_update: :update_all), null: false
      add :permission_id, references(:permissions, on_delete: :restrict, on_update: :update_all), null: false
    end

    create unique_index(:permission_set_permissions, [:permission_set_id, :permission_id])

    create table(:permission_set_grants) do
      add :permission_set_id, references(:permission_sets, on_delete: :restrict, on_update: :update_all), null: false
      add :grantee_id, references(:users, on_delete: :restrict, on_update: :update_all), null: false
      add :authority_id, references(:users, on_delete: :restrict, on_update: :update_all), null: false
      add :valid_after, :bigint
      add :valid_for, :bigint
      add :inserted_at, :naive_datetime, default: fragment("now()::timestamp"), null: false
    end

    create index(:permission_set_grants, [:grantee_id])

    create table(:permission_set_grant_invalidations) do
      add :grant_id, references(:permission_set_grants, on_delete: :delete_all, on_update: :update_all), null: false
      add :authority_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
      add :inserted_at, :naive_datetime, default: fragment("now()::timestamp"), null: false
    end

    create table(:passphrases) do
      add :user_id, references(:users, on_delete: :restrict, on_update: :update_all), null: false
      add :passkey_digest, :binary, null: false
      add :ip_addr, :inet, null: false
      add :inserted_at, :naive_datetime, default: fragment("now()::timestamp"), null: false
    end

    create index(:passphrases, [:user_id])
    create index(:passphrases, [:ip_addr])

    create table(:passphrase_invalidations) do
      add :source_passphrase_id, references(:passphrases, on_delete: :delete_all, on_update: :update_all), null: false
      add :target_passphrase_id, references(:passphrases, on_delete: :delete_all, on_update: :update_all), null: false
      add :inserted_at, :naive_datetime, default: fragment("now()::timestamp"), null: false
    end

    create unique_index(:passphrase_invalidations, [:target_passphrase_id])
    create index(:passphrase_invalidations, [:source_passphrase_id])

    env = Application.get_env(:legion, Legion.Identity.Auth.Concrete)
    user_agent_length = Keyword.fetch!(env, :user_agent_length)

    create table(:activities) do
      add :passphrase_id, references(:passphrases, on_delete: :restrict, on_update: :update_all), null: false
      add :user_agent, :string, size: user_agent_length, null: false
      add :engine, :text
      add :engine_version, :text
      add :client_name, :text
      add :client_type, :text
      add :client_version, :text
      add :device_brand, :text
      add :device_model, :text
      add :device_type, :text
      add :os_name, :text
      add :os_platform, :text
      add :os_version, :text
      add :ip_addr, :inet, null: false
      add :country_name, :text
      add :country_code, :text
      add :ip_location, :point
      add :metro_code, :text
      add :region_code, :text
      add :region_name, :text
      add :time_zone, :text
      add :zip_code, :text
      add :gps_location, :point
      add :inserted_at, :naive_datetime, default: fragment("now()::timestamp"), null: false
    end

    create index(:activities, [:passphrase_id])
    create index(:activities, [:engine])
    create index(:activities, [:os_name])
    create index(:activities, [:country_name])
    create index(:activities, [:country_code])
    create index(:activities, [:ip_addr])

    create table(:concrete_tfa_handles) do
      add :user_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
      add :otc_digest, :binary, null: false
      add :passphrase_id, references(:passphrases, on_delete: :delete_all, on_update: :update_all)
      add :attempts, :integer, default: 0, null: false
      add :inserted_at, :naive_datetime, default: fragment("now()::timestamp"), null: false
    end

    create index(:concrete_tfa_handles, [:passphrase_id])
    create index(:concrete_tfa_handles, [:user_id], where: "attempts < #{@allowed_otc_attempts}")

    create table(:messages) do
      add :sender_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
      add :subject, :text
      add :body, :text, null: false
      add :medium, :messaging_medium, null: false
      add :send_after, :integer, null: false, default: 0
      add :inserted_at, :naive_datetime, default: fragment("now()::timestamp"), null: false
    end

    create table(:messaging_settings_registers, primary_key: false) do
      add :key, :text, null: false, primary_key: true
    end

    create table(:messaging_settings_registry_entries) do
      add :key, references(:messaging_settings_registers, on_delete: :delete_all, on_update: :update_all, column: :key, type: :text), null: false
      add :value, :jsonb, null: false
      add :authority_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
      add :inserted_at, :naive_datetime, default: fragment("now()::timestamp"), null: false
    end

    create index(:messaging_settings_registry_entries, [:key])
    create index(:messaging_settings_registry_entries, [:authority_id])

    create table(:message_recipients, primary_key: false) do
      add :message_id, references(:messages, on_delete: :delete_all, on_update: :update_all), null: false
      add :recipient_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
    end

    create unique_index(:message_recipients, [:message_id, :recipient_id])

    create table(:message_success_informations) do
      add :message_id, references(:messages, on_delete: :delete_all, on_update: :update_all), null: false
      add :inserted_at, :naive_datetime, default: fragment("now()::timestamp"), null: false
    end

    create table(:messaging_templates) do
      add :user_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
      add :name, :text, null: false
      add :engine, :template_rendering_engine, null: false
      add :subject_template, :text, null: false
      add :body_template, :text, null: false
      add :is_available_for_apm?, :boolean, null: false
      add :is_available_for_push?, :boolean, null: false
      add :is_available_for_mailing?, :boolean, null: false
      add :is_available_for_sms?, :boolean, null: false
      add :is_available_for_platform?, :boolean, null: false
      add :inserted_at, :naive_datetime, default: fragment("now()::timestamp"), null: false
    end

    create table(:message_template_usages) do
      add :message_id, references(:messages, on_delete: :delete_all, on_update: :update_all), null: false, primary_key: true
      add :template_id, references(:messaging_templates, on_delete: :delete_all, on_update: :update_all), null: false
      add :subject_params, :jsonb, null: false
      add :body_params, :jsonb, null: false
    end

    create table(:insecure_authentication_pairs) do
      add :user_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
      add :username, :string, null: false
      add :password_digest, :string, null: false
      add :digestion_algorithm, :digestion_algorithm, null: false
      add :inserted_at, :naive_datetime, default: fragment("now()::timestamp"), null: false
    end
  end
end
