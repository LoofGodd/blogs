defmodule Loofgodd.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :post_id, references(:posts, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:likes, [:post_id, :user_id])
    create index(:likes, [:post_id])
    create index(:likes, [:user_id])
  end
end
