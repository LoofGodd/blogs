defmodule Loofgodd.Blog.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :status, :string
    field :content, :string
    field :post_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :status])
    |> validate_required([:content, :status])
  end
end
