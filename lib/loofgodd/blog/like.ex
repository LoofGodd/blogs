defmodule Loofgodd.Blog.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do

    field :post_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [])
    |> validate_required([])
  end
end
