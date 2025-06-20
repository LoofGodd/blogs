defmodule Loofgodd.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Loofgodd.Repo
  alias Loofgodd.Blog.{PostRevision, Tag}

  schema "posts" do
    field :status, :string
    field :content, :string
    field :title, :string
    field :slug, :string
    field :scheduled, :utc_datetime
    field :published_at, :utc_datetime
    field :viewer, :integer
    field :is_pinned, :boolean, default: false

    belongs_to :user, Loofgodd.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [
      :title,
      :slug,
      :content,
      :status,
      :scheduled,
      :published_at,
      :viewer,
      :is_pinned,
      :user_id
    ])
    |> validate_required([:title, :content, :status, :published_at])
    |> put_change(:slug, generate_slug(attrs[:title]))
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:user_id, message: "does not exist")
  end

  defp generate_slug(nil), do: nil

  defp generate_slug(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/[\s+]/, "-")
  end

  defp post_changeset(post, attrs, user_id) do
    post
    |> changeset(attrs)
    |> put_change(:user_id, user_id)
  end

  defp create_post(attrs, user_id) do
    %__MODULE__{}
    |> post_changeset(attrs, user_id)
    |> Repo.insert()
  end

  def create_blog(attrs, user_id) do
    tag_names =
      attrs
      |> Map.get(:tag_names, "")
      |> String.split(~r{[\s,;\-]+}, trim: true)

    Repo.transact(fn ->
      with {:ok, post} <- create_post(attrs, user_id),
           {:ok, _} <- PostRevision.create(post, attrs),
           {:ok, _} <- Tag.insert_all(post, tag_names) do
        {:ok, post}
      end
    end)
  end
end
