defmodule Loofgodd.Accounts.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "permissions" do
    field :name, :string
    field :description, :string
    many_to_many :roles, Loofgodd.Accounts.Role, join_through: "roles_permissions"
    timestamps()
  end

  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
