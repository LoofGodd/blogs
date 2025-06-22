defmodule Loofgodd.Blog.PostTag do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Loofgodd.Repo

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
  end

  def get(post, tag) do
    Repo.get_by(__MODULE__, post_id: post.id, tag_id: tag.id)
  end

  def create(post, tag) do
    %__MODULE__{}
    |> changeset(%{post_id: post.id, tag_id: tag.id})
    |> Repo.insert(on_conflict: :replace_all, conflict_target: [:post_id, :tag_id])
  end

  def count_tags(tag) do
    Repo.aggregate(
      from(pt in __MODULE__, where: pt.tag_id == ^tag.id),
      :count,
      :post_id
    )
  end
end
