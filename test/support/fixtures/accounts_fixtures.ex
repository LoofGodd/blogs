defmodule Loofgodd.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Loofgodd.Accounts` context.
  """
  alias Loofgodd.Accounts.Role
  alias Loofgodd.Repo

  def unique, do: System.unique_integer([:positive, :monotonic])
  def unique_user_email, do: "user#{unique()}@example.com"
  def valid_user_password, do: "hello world!"
  def username, do: "LoofGodd#{unique()}}"

  def valid_user_attributes(attrs \\ %{}) do
    attrs = Map.merge(%{role_id: 1}, attrs)

    Enum.into(attrs, %{
      username: username(),
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def role_fixture(attrs \\ %{}) do
    {:ok, role} =
      %Role{}
      |> Role.changeset(
        Map.merge(%{name: "super_admin", description: "Unrestricted access"}, attrs)
      )
      |> Repo.insert(on_conflict: :nothing)

    role
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Loofgodd.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
