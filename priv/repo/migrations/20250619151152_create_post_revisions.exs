defmodule Loofgodd.Repo.Migrations.CreatePostRevisions do
  use Ecto.Migration

  def change do
    create table(:post_revisions) do
      add :title, :string
      add :content, :text
      add :revision_note, :text
      add :post_id, references(:posts, on_delete: :nothing)
      add :created_by, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:post_revisions, [:post_id])
    create index(:post_revisions, [:created_by])
  end
end
