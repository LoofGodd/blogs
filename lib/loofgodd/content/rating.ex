defmodule Loofgodd.Content.Rating do
  use Ecto.Schema
  import Ecto.Changeset
  alias Loofgodd.Repo

  schema "ratings" do
    field :rating, :integer
    field :review, :string
    belongs_to :post, Loofgodd.Blog.Post
    belongs_to :user, Loofgodd.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:rating, :review, :post_id, :user_id])
    |> validate_required([:rating, :review, :post_id, :user_id])
  end

  def upsert(rating, attrs) do
    rating
    |> changeset(attrs)
    |> Repo.insert_or_update()
  end
end
