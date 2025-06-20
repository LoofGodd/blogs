defmodule Loofgodd.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :user_id, references(:users, on_delete: :nothing)
      add :author_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:subscriptions, [:user_id])
    create index(:subscriptions, [:author_id])
  end
end
