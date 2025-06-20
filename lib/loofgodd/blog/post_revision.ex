defmodule Loofgodd.Blog.PostRevision do
  use Ecto.Schema
  import Ecto.Changeset
  alias Loofgodd.Blog.PostRevision
  alias Loofgodd.Repo

  schema "post_revisions" do
    field :title, :string
    field :content, :string
    field :revision_note, :string
    belongs_to :post, Loofgodd.Blog.Post
    field :created_by, :id

    timestamps(type: :utc_datetime)
  end

  @doc false

  def changeset(post_revision, attrs) do
    post_revision
    |> cast(attrs, [:title, :content, :revision_note, :post_id, :created_by])
    |> validate_required([:title, :content, :post_id, :created_by])
  end

  def create(post, attrs) do
    attrs =
      Map.merge(attrs, %{
        post_id: post.id,
        created_by: post.user_id,
        revision_note: attrs[:revision_note] || "No revision note provided"
      })

    %PostRevision{}
    |> changeset(attrs)
    |> Repo.insert()
  end
end
