defmodule Loofgodd.Blog.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :status, :string
    field :content, :string
    belongs_to :post, Loofgodd.Blog.Post

    has_many :replies, __MODULE__, foreign_key: :parent_id
    belongs_to :parent, __MODULE__
    belongs_to :user, Loofgodd.Accounts.User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :status, :post_id, :user_id, :parent_id])
    |> validate_required([:content, :status, :post_id, :user_id])
    |> assoc_constraint(:post)
    |> assoc_constraint(:parent)
  end

  def upsert(comment, attrs) do
    comment
    |> changeset(attrs)
    |> Loofgodd.Repo.insert_or_update()
  end
end
