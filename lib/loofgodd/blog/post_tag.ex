defmodule Loofgodd.Blog.PostTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post_tags" do
    # these will become the composite primary key
    belongs_to :post, Loofgodd.Blog.Post
    belongs_to :tag, Loofgodd.Blog.Tag

    timestamps(type: :utc_datetime)
  end

  @doc false

  def changeset(post_tag, attrs) do
    post_tag
    |> cast(attrs, [:post_id, :tag_id])
    |> validate_required([:post_id, :tag_id])
    |> unique_constraint([:post_id, :tag_id])
    |> foreign_key_constraint(:post_id, message: "Post Id not exist")
    |> foreign_key_constraint(:tag_id, message: "Tag Id not exist")
  end

  def create(post, tag) do
    %__MODULE__{}
    |> changeset(%{post_id: post.id, tag_id: tag.id})
    |> Loofgodd.Repo.insert()
  end
end
