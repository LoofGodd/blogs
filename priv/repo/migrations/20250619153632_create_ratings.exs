defmodule Loofgodd.Repo.Migrations.CreateRatings do
  use Ecto.Migration

  def change do
    create table(:ratings) do
      add :rating, :integer
      add :review, :text
      add :post_id, references(:posts, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:ratings, [:post_id])
    create index(:ratings, [:user_id])
  end
end
