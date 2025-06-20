defmodule Loofgodd.Repo.Migrations.CreateRolesPermissionsTable do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string, null: false
      add :description, :text, null: true
      timestamps(type: :utc_datetime)
    end

    create unique_index(:roles, [:name])

    create table(:permissions) do
      add :name, :string, null: false
      add :description, :text, null: true
      timestamps(type: :utc_datetime)
    end

    create unique_index(:permissions, [:name])

    create table(:roles_permissions) do
      add :role_id, references(:roles, on_delete: :delete_all), null: false
      add :permission_id, references(:permissions, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:roles_permissions, [:role_id, :permission_id])
  end
end
