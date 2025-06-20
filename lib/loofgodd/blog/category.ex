defmodule Loofgodd.Blog.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :description, :string
    field :parent_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
