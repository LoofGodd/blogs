defmodule Loofgodd.Repo.Migrations.CreateCategoies do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :description, :string
      add :parent_id, references(:categories, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:categories, [:parent_id])
  end
end
