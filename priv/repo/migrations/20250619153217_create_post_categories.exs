defmodule Loofgodd.Repo.Migrations.CreatePostCategories do
  use Ecto.Migration

  def change do
    create table(:post_categories) do
      add :post_id, references(:posts, on_delete: :nothing)
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:post_categories, [:post_id])
    create index(:post_categories, [:category_id])
  end
end
