defmodule Loofgodd.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table(:visits) do
      add :visitor_ip, :string
      add :time_spent, :integer
      add :visit_date, :date
      add :referrer, :string
      add :post_id, references(:posts, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:visits, [:post_id])
  end
end
