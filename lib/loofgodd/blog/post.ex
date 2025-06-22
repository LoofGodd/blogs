defmodule Loofgodd.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Loofgodd.Repo

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
  def logger(v) do
    IO.inspect(v, label: "Post Logger")
    v
  end

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
    |> put_change(:user_id, attrs[:user_id])
    |> unique_constraint(:slug)
  end

  defp generate_slug(nil), do: nil

  defp(generate_slug(title)) do
    title
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/[\s+]/, "-")
  end

  def delete(post) do
    Repo.delete(post)
  end

  def upsert(post, attrs) do
    IO.inspect(attrs[:title], label: "attrs")

    post
    |> changeset(attrs)
    |> Repo.insert_or_update()
  end
end
