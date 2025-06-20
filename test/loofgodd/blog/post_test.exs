defmodule Loofgodd.Blog.PostTest do
  use Loofgodd.DataCase

  import Loofgodd.AccountsFixtures
  alias Loofgodd.Blog.{Post, PostRevision, PostTag, Tag}
  alias Loofgodd.Repo
  alias Loofgodd.Accounts
  alias Loofgodd.Accounts.User
  alias Loofgodd.Accounts.Role

  describe("create_post/3") do
    setup do
      {:ok, role} =
        %Role{}
        |> Role.changeset(%{name: "super_admin", description: "Unrestricted access"})
        |> Repo.insert(onconflict: :nothing, table: "name")

      IO.inspect(role, label: "Role created")

      {:ok, %User{} = user} =
        Accounts.register_user(%{
          :email => unique_user_email(),
          :username => username(),
          :password => valid_user_password(),
          :role_id => role.id
        })

      valid_attrs = %{
        title: "Test Post",
        content:
          ~s({"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"Hello"}]}]}),
        slug: "test-post",
        status: "draft",
        tag_names: "Elixir, Phoenix",
        revision_note: "Initial draft",
        published_at: DateTime.utc_now() |> DateTime.truncate(:second)
      }

      {:ok, user: user, valid_attrs: valid_attrs}
    end

    test "creates a post with valid attributes, revision, and tags", %{
      user: user,
      valid_attrs: attrs
    } do
      assert {:ok, %Post{} = post} = Post.create_blog(attrs, user.id)

      assert post.title == attrs[:title]
      assert post.content == attrs[:content]
      assert post.user_id == user.id
      assert post.slug == attrs[:slug]
      assert post.status == attrs[:status]

      # Verify revision
      revision = Repo.get_by!(PostRevision, post_id: post.id)
      assert revision.title == post.title
      assert revision.content == post.content
      assert revision.revision_note == "Initial draft"
      assert revision.created_by == user.id

      # Verify tags

      tags =
        Repo.all(
          from t in Tag,
            where: t.id in fragment("SELECT tag_id FROM post_tags WHERE post_id = ?", ^post.id)
        )

      assert length(tags) == 2
      assert Enum.map(tags, & &1.name) |> Enum.sort() == ["Elixir", "Phoenix"]
      assert Enum.all?(tags, &(&1.usage_count == 1))

      # Verify post_tags
      post_tags = Repo.all(PostTag, post_id: post.id)
      assert length(post_tags) == 2
    end

    test "increments usage_count for existing tags", %{user: user, valid_attrs: attrs} do
      # Pre-create a tag
      %Tag{name: "Elixir", usage_count: 5} |> Repo.insert!()

      assert {:ok, _} = Post.create_blog(attrs, user.id)
      tag = Repo.get_by!(Tag, name: "Elixir")
      # Incremented from 5
      assert tag.usage_count == 6
    end

    test "returns error for invalid attributes", %{user: user} do
      invalid_attrs = %{"title" => "", "content" => "", "tag_names" => "Elixir"}

      assert {:error, %Ecto.Changeset{} = changeset} =
               Post.create_blog(invalid_attrs, user.id)

      IO.inspect(errors_on(changeset)[:title] == ["can't be blank"], label: "Changeset Error")
      # assert errors_on(changeset)[:title] == ["can't be blank"]
      # assert errors_on(changeset)[:content] == ["can't be blank"]
      #
      # # Verify no post, revision, or tags were created
      assert Repo.aggregate(Post, :count, :id) == 0
      assert Repo.aggregate(PostRevision, :count, :id) == 0
      assert Repo.aggregate(Tag, :count, :id) == 0
    end

    test "handles duplicate slug gracefully", %{user: user, valid_attrs: attrs} do
      # Create a post with the same slug
      Post.create_blog(attrs, user.id)

      # Try creating another post with the same slug
      assert {:error, %Ecto.Changeset{} = changeset} = Post.create_blog(attrs, user.id)
      assert errors_on(changeset)[:slug] == ["has already been taken"]
    end

    test "creates post without tags if tag_names is empty", %{user: user, valid_attrs: attrs} do
      attrs = Map.put(attrs, :tag_names, "")
      assert {:ok, %Post{} = post} = Post.create_blog(attrs, user.id)
      assert post.title == "Test Post"

      # Verify no tags or post_tags
      assert Repo.aggregate(Tag, :count, :id) == 0
      assert Repo.aggregate(PostTag, :count, :id) == 0

      # Verify revision exists
      assert Repo.get_by!(PostRevision, post_id: post.id)
    end

    test "returns error if user_id is invalid", %{valid_attrs: attrs} do
      invalid_user_id = 999

      assert {:error, %Ecto.Changeset{} = changeset} =
               Post.create_blog(attrs, invalid_user_id)

      assert errors_on(changeset)[:user_id] == ["does not exist"]
    end
  end
end
