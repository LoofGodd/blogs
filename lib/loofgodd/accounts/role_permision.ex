defmodule Loofgodd.Accounts.RolePermission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles_permissions" do
    belongs_to :role, Loofgodd.Accounts.Role
    belongs_to :permission, Loofgodd.Accounts.Permission

    timestamps(type: :utc_datetime)
  end

  def changeset(role_permission, attrs) do
    role_permission
    |> cast(attrs, [:role_id, :permission_id])
    |> validate_required([:role_id, :permission_id])
    |> unique_constraint([:role_id, :permission_id])
    |> foreign_key_constraint(:role_id)
    |> foreign_key_constraint(:permission_id)
  end
end
