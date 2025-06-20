defmodule Loofgodd.Blog.PostCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post_categories" do

    field :post_id, :id
    field :category_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post_category, attrs) do
    post_category
    |> cast(attrs, [])
    |> validate_required([])
  end
end
