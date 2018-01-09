defmodule Legion.Repo.Migrations.CreateInitialTables do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :has_gps_telemetry_consent?, :boolean, default: false
      add :inserted_at, :naive_datetime, default: fragment("now()"), null: false
    end

    create table(:permissions) do
      add :controller_name, :text, null: false
      add :controller_action, :text, null: false
      add :type, :text, null: false
    end

    create unique_index(:permissions, [:controller_name, :controller_action, :type])
    create unique_index(:permissions, [:controller_name, :controller_action])
    create unique_index(:permissions, [:type])

    create table(:permission_sets) do
      add :name, :text, null: false
      add :inserted_at, :naive_datetime, default: fragment("now()"), null: false
    end

    create unique_index(:permission_sets, [:name])

    create table(:permission_set_permissions) do
      add :permission_set_id, references(:permission_sets, on_delete: :restrict, on_update: :update_all)
      add :permission_id, references(:permissions, on_delete: :restrict, on_update: :update_all)
    end

    create unique_index(:permission_set_permissions, [:permission_set_id, :permission_id])

    create table(:permission_set_grants) do
      add :permission_set_id, references(:permission_sets, on_delete: :restrict, on_update: :update_all), null: false
      add :grantee_id, references(:users, on_delete: :restrict, on_update: :update_all), null: false
      add :authority_id, references(:users, on_delete: :restrict, on_update: :update_all), null: false
      add :valid_after, :bigint
      add :valid_for, :bigint
      add :inserted_at, :naive_datetime, default: fragment("now()"), null: false
    end

    create table(:permission_set_grant_invalidations) do
      add :grant_id, references(:permission_set_grants, on_delete: :delete_all, on_update: :update_all), null: false
      add :authority_id, references(:users, on_delete: :delete_all, on_update: :update_all), null: false
      add :inserted_at, :naive_datetime, default: fragment("now()"), null: false
    end

    create table(:passphrases) do
      add :user_id, references(:users, on_delete: :restrict, on_update: :update_all), null: false
      add :passkey_digest, :string, size: 400
      add :ip_addr, :inet, null: false
      add :inserted_at, :naive_datetime, default: fragment("now()"), null: false
    end

    create index(:passphrases, [:user_id])
    create index(:passphrases, [:ip_addr])

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
      add :inserted_at, :naive_datetime, default: fragment("now()"), null: false
    end
  end
end
