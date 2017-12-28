defmodule Legion.Repo.Migrations.CreateInitialTables do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :inserted_at, :naive_datetime, default: fragment("now()"), null: false
    end

    create table(:permissions) do
      add :controller_name, :string, null: false
      add :controller_action, :string, null: false
      add :type, :string, null: false
    end

    create unique_index(:permissions, [:controller_name, :controller_action, :type])
    create unique_index(:permissions, [:controller_name, :controller_action])
    create unique_index(:permissions, [:type])

    create table(:permission_sets) do
      add :name, :string, null: false
      add :inserted_at, :naive_datetime, default: fragment("now()"), null: false
    end

    create unique_index(:permission_sets, [:name])

    create table(:permission_set_permissions) do
      add :permission_set_id, references(:permission_sets, on_delete: :restrict, on_update: :update_all)
      add :permission_id, references(:permissions, on_delete: :restrict, on_update: :update_all)
    end

    create unique_index(:permission_set_permissions, [:permission_set_id, :permission_id])
  end
end
