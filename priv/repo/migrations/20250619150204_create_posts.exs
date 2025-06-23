defmodule Loofgodd.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :slug, :string
      add :content, :text
      add :status, :string
      add :scheduled, :utc_datetime
      add :published_at, :utc_datetime
      add :viewer, :integer
      add :is_pinned, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:posts, [:slug])
    create index(:posts, [:user_id, :status])
  end
end
