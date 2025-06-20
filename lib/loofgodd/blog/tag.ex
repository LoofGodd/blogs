defmodule Loofgodd.Blog.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias Loofgodd.Repo
  alias Loofgodd.Blog.PostTag

  schema "tags" do
    field :name, :string
    field :usage_count, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :usage_count])
    |> validate_required([:name, :usage_count])
    |> foreign_key_constraint(:name, message: "does not exist")
  end

  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert(
      on_conflict: [inc: [usage_count: 1]],
      conflict_target: :name
    )
  end

  def insert_all(post, tag_names) when is_list(tag_names) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    entries =
      tag_names
      # avoid duplicate work in this batch
      |> Enum.uniq()
      |> Enum.map(fn name ->
        %{name: name, usage_count: 1, inserted_at: now, updated_at: now}
      end)

    {_count, tags} =
      Repo.insert_all(
        __MODULE__,
        entries,
        on_conflict: [inc: [usage_count: 1]],
        conflict_target: [:name],
        returning: true
      )

    tags
    |> Enum.uniq()
    |> Enum.map(fn tag ->
      PostTag.create(post, tag)
    end)

    {:ok, tags}
  end
end
