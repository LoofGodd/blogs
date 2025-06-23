defmodule Loofgodd.Blog.Like do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "likes" do
    belongs_to :post, Loofgodd.Blog.Post
    belongs_to :user, Loofgodd.Accounts.User
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:post_id, :user_id, :inserted_at, :updated_at])
    |> validate_required([:post_id, :user_id])
    |> unique_constraint([:post_id, :user_id])
  end

  @doc "Creates a like."
  def create(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Loofgodd.Repo.insert()
  end

  @doc "Toggles a like by post_id and user_id."
  def toggle(attrs) do
    {count, _} =
      Loofgodd.Repo.delete_all(
        from(l in __MODULE__,
          where: l.post_id == ^attrs[:post_id] and l.user_id == ^attrs[:user_id]
        )
      )

    if count == 0 do
      create(attrs)
    else
      {:ok}
    end
  end
end
