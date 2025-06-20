defmodule Loofgodd.Seeds.Users do
  alias Loofgodd.Repo
  alias Loofgodd.Accounts.{User, Role}

  alias Loofgodd.Accounts

  def seed do
    roles = %{
      "super_admin" => Repo.get_by!(Role, name: "super_admin"),
      "author" => Repo.get_by!(Role, name: "author"),
      "subscriber" => Repo.get_by!(Role, name: "subscriber")
    }

    users = [
      %{
        username: "superadmin",
        email: "superadmin@example.com",
        password: "password123",
        role_id: roles["super_admin"].id
      },
      %{
        username: "author1",
        email: "author1@example.com",
        password: "password123",
        role_id: roles["author"].id
      },
      %{
        username: "subscriber1",
        email: "subscriber1@example.com",
        password: "password123",
        role_id: roles["subscriber"].id
      }
    ]

    Enum.each(users, fn attrs ->
      Accounts.register_user(attrs)
    end)
  end
end

# Run seeds
