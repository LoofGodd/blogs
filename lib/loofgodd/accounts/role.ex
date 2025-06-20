defmodule Loofgodd.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :name, :string
    field :description, :string
    many_to_many :permissions, Loofgodd.Accounts.Permission, join_through: "roles_permissions"
    timestamps()
  end

  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
