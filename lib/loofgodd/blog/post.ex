defmodule Loofgodd.Blog.Post do
  use Ecto.Schema
  use Timex
  import Ecto.Changeset
  import Ecto.Query
  alias Loofgodd.Repo
  alias Loofgodd.Blog.Like

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

    many_to_many :tags, Loofgodd.Blog.Tag, join_through: Loofgodd.Blog.PostTag
    has_many :likes, Loofgodd.Blog.Like
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

  defp generate_slug(nil), do: "#{System.unique_integer()}"

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
    post
    |> changeset(attrs)
    |> Repo.insert_or_update()
  end

  @periods ~w(day week month year)

  def top_posts_by_period(period, limit \\ 5) do
    unless period in @periods and is_integer(limit) do
      raise ArgumentError, "Invalid period: #{period}. Valid periods are: #{@periods}"
    end

    now = DateTime.utc_now() |> DateTime.truncate(:second)

    cutoff =
      case period do
        "day" -> Timex.beginning_of_day(now)
        "week" -> Timex.beginning_of_week(now, :sun)
        "month" -> Timex.beginning_of_month(now)
        "year" -> Timex.beginning_of_year(now)
      end

    from(p in __MODULE__,
      join: l in assoc(p, :likes),
      where: p.status == "published" and l.updated_at >= ^cutoff,
      group_by: [p.id, p.title],
      select: %{
        post_id: p.id,
        post_title: p.title,
        likes_count: count(l.id),
        period_start: ^cutoff
      },
      order_by: [desc: count(l.id)],
      limit: ^limit
    )
    |> Repo.all()
  end

  def likes_post_by_user(user_id, limit \\ 5) do
    from(
      p in __MODULE__,
      where: p.status == "published",
      join: ul in assoc(p, :likes),
      on: ul.user_id == ^user_id,
      preload: [:user],
      limit: ^limit
    )
    |> Repo.all()
  end

  def count_likes(post) do
    Loofgodd.Repo.aggregate(Like, :count, :id, where: [post_id: post.id])
  end
end
