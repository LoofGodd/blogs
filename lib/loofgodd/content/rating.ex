defmodule Loofgodd.Content.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ratings" do
    field :rating, :integer
    field :review, :string
    field :post_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:rating, :review])
    |> validate_required([:rating, :review])
  end
end
