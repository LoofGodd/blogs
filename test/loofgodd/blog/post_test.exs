defmodule Loofgodd.Blog.PostTest do
  use Loofgodd.DataCase

  import Loofgodd.AccountsFixtures
  alias Loofgodd.Blog.{Post, PostRevision, PostTag, Tag}
  alias Loofgodd.Blog
  alias Loofgodd.Repo
  alias Loofgodd.Accounts
  alias Loofgodd.Accounts.User
  alias Loofgodd.Accounts.Role

  describe("create_post/3 ==> ") do
    setup do
      {:ok, role} =
        %Role{}
        |> Role.changeset(%{name: "super_admin", description: "Unrestricted access"})
        |> Repo.insert(onconflict: :nothing, table: "name")

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
        status: "draft",
        tag_names: "Elixir, Phoenix",
        revision_note: "Initial draft",
        published_at: DateTime.utc_now() |> DateTime.truncate(:second),
        user_id: user.id
      }

      {:ok, user: user, valid_attrs: valid_attrs}
    end

    test "creates a post with valid attributes, revision, and tags", %{valid_attrs: attrs} do
      assert {:ok, %Post{} = post} = Blog.upsert_blog(%Post{}, attrs)

      assert post.title == attrs[:title]
      assert post.content == attrs[:content]
      assert post.user_id == attrs[:user_id]
      assert post.slug != nil
      assert post.status == attrs[:status]

      # Verify revision
      revision = Repo.get_by!(PostRevision, post_id: post.id)
      assert revision.title == post.title
      assert revision.content == post.content
      assert revision.revision_note == "Initial draft"
      assert revision.created_by == attrs[:user_id]

      tags =
        Repo.all(
          from t in Tag,
            where:
              t.id in subquery(
                from pt in "post_tags",
                  select: pt.tag_id,
                  where: pt.post_id == ^post.id
              )
        )

      assert length(tags) == 2
      assert Enum.map(tags, & &1.name) |> Enum.sort() == ["Elixir", "Phoenix"]
      assert Enum.all?(tags, &(&1.usage_count == 1))

      # Verify post_tags
      post_tags = Repo.all(PostTag, post_id: post.id)
      assert length(post_tags) == 2
    end

    test "increments usage_count for existing tags", %{valid_attrs: attrs} do
      {:ok, _} = Blog.upsert_blog(%Post{}, attrs)

      {:ok, _} =
        Blog.upsert_blog(%Post{}, %{attrs | title: "Another Post", tag_names: "Elixir, LOVELY"})

      # IO.inspect(Repo.all(from p in Post, select: [p.id, p.title]), label: "Post after created")
      #
      # IO.inspect(Repo.all(from t in Tag, select: [t.id, t.name, t.usage_count]),
      #   label: "Tag after created"
      # )
      #
      # IO.inspect(Repo.all(from pt in PostTag, select: [pt.post_id, pt.tag_id]),
      #   label: "Post Tag after created"
      # )

      # IO.inspect(Repo.all(Tag), label: "Tag after created")
      # IO.inspect(Repo.all(PostTag), label: "Post Tag after created")
      tag = Repo.get_by!(Tag, name: "Elixir")

      assert tag.usage_count == 2
    end

    test "returns error for invalid attributes", _ do
      invalid_attrs = %{title: "", content: "", tag_names: "Elixir"}

      assert {:error, %Ecto.Changeset{} = changeset} =
               Blog.upsert_blog(%Post{}, invalid_attrs)

      assert errors_on(changeset)[:title] == ["can't be blank"]
      assert errors_on(changeset)[:content] == ["can't be blank"]

      #  Verify no post, revision, or tags were created
      assert Repo.aggregate(Post, :count, :id) == 0
      assert Repo.aggregate(PostRevision, :count, :id) == 0
      assert Repo.aggregate(Tag, :count, :id) == 0
    end

    test "handles duplicate slug gracefully", %{valid_attrs: attrs} do
      {:ok, _post} = Blog.upsert_blog(%Post{}, attrs)

      {:error, %Ecto.Changeset{} = changeset} = Blog.upsert_blog(%Post{}, attrs)
      assert errors_on(changeset)[:slug] == ["has already been taken"]
    end

    test "creates post without tags if tag_names is empty", %{valid_attrs: attrs} do
      attrs = Map.put(attrs, :tag_names, "")
      assert {:ok, %Post{} = post} = Blog.upsert_blog(%Post{}, attrs)
      assert post.title == attrs[:title]

      # Verify no tags or post_tags
      assert Repo.aggregate(Tag, :count, :id) == 0
      assert Repo.aggregate(PostTag, :count, :id) == 0

      # Verify revision exists
      assert Repo.get_by!(PostRevision, post_id: post.id)
    end

    test "updated post", %{valid_attrs: attrs} do
      {:ok, post} = Blog.upsert_blog(%Post{}, attrs)

      updated_attrs =
        attrs
        |> Map.put(:title, "Updated Post")
        |> Map.put(:content, "Updated content")

      # 3) call upsert_blog with the existing struct _and_ the new attrs
      assert {:ok, %Post{} = new_post} = Blog.upsert_blog(post, updated_attrs)
      assert new_post.title == "Updated Post"
      assert new_post.content == "Updated content"
    end
  end
end
