defmodule Loofgodd.Blog.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Loofgodd.Repo
  alias Loofgodd.Blog.PostTag

  schema "tags" do
    field :name, :string
    field :usage_count, :integer

    timestamps(type: :utc_datetime)
  end

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :usage_count])
    |> validate_required([:name, :usage_count])
    |> foreign_key_constraint(:name, message: "does not exist")
  end

  def insert_all(post, tag_names) when is_list(tag_names) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    tag_names
    |> Enum.uniq()
    |> Enum.map(fn name ->
      %{name: name, usage_count: 1, inserted_at: now, updated_at: now}
    end)
    |> then(fn entries ->
      Repo.insert_all(__MODULE__, entries,
        on_conflict: :nothing,
        on_conflict_target: [:name]
      )

      from(t in __MODULE__, where: t.name in ^tag_names)
      |> Repo.all()
    end)
    |> Enum.each(fn tag ->
      PostTag.create(post, tag)

      count_tages = PostTag.count_tags(tag)

      tag
      |> changeset(%{usage_count: count_tages})
      |> Repo.update()
    end)

    {:ok, "nick"}
  end
end
