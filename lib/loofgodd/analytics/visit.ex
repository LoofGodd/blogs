defmodule Loofgodd.Analytics.Visit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "visits" do
    field :visitor_ip, :string
    field :time_spent, :integer
    field :visit_date, :date
    field :referrer, :string
    field :post_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:visitor_ip, :time_spent, :visit_date, :referrer])
    |> validate_required([:visitor_ip, :time_spent, :visit_date, :referrer])
  end
end
