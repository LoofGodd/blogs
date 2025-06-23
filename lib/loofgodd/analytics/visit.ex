defmodule Loofgodd.Analytics.Visit do
  use Ecto.Schema
  import Ecto.Changeset
  alias Loofgodd.Repo

  schema "visits" do
    field :visitor_ip, :string
    field :time_spent, :integer
    field :visit_date, :date
    field :leave_date, :date, virtual: true
    field :referrer, :string
    field :post_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:visitor_ip, :visit_date, :leave_date, :referrer])
    |> validate_required([:visitor_ip, :time_spent, :visit_date, :leave_date, :referrer])
    |> put_change(:time_spent, calculate_time_spent(attrs))
  end

  def calculate_time_spent(visit) do
    DateTime.diff(visit.leave_date, visit.visit_date, :second)
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end
end
