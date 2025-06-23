defmodule Loofgodd.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :text
      add :status, :string
      add :post_id, references(:posts, on_delete: :nothing)
      add :parent_id, references(:comments, on_delete: :delete_all), null: true
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:post_id])
    create index(:comments, [:user_id])
  end
end
