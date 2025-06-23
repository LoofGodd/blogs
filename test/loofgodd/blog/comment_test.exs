defmodule Loofgodd.Blog.CommentTest do
  use Loofgodd.DataCase
  import Loofgodd.AccountsFixtures
  import Loofgodd.Blog.BlogFixtures
  alias Loofgodd.Blog.{Comment, Post}

  describe "Comment Schema" do
    setup do
      role_fixture()
      user = user_fixture()

      post =
        post_fixture()

      valid_attrs = %{
        content: "This is a test comment",
        status: "published",
        post_id: post.id,
        user_id: user.id
      }

      {:ok, user: user, post: post, valid_attrs: valid_attrs}
    end

    test "create, update and reply", %{valid_attrs: attrs} do
      assert {:ok, comment} = Comment.upsert(%Comment{}, attrs)
      assert {:error, changeset} = Comment.upsert(%Comment{}, %{})
      assert changeset.valid? == false
      assert errors_on(changeset)[:content] == ["can't be blank"]
      assert errors_on(changeset)[:status] == ["can't be blank"]
      assert errors_on(changeset)[:post_id] == ["can't be blank"]
      assert errors_on(changeset)[:user_id] == ["can't be blank"]

      attrs = %{attrs | content: "Updated content"}
      assert {:ok, comment} = Comment.upsert(comment, attrs)
      assert comment.content == "Updated content"

      loofgodd = user_fixture(%{username: "loofgodd"})
      join = user_fixture(%{username: "join"})

      commment_attrs =
        Map.merge(attrs, %{
          content: "This is a reply",
          user_id: loofgodd.id,
          parent_id: comment.id
        })

      commment_attrs2 =
        Map.merge(attrs, %{
          content: "This is a reply",
          user_id: join.id,
          parent_id: comment.id
        })

      comment_reply = Comment.upsert(%Comment{}, commment_attrs)

      comment_reply2 = Comment.upsert(%Comment{}, commment_attrs2)

      comments = Post.list_comments(attrs.post_id)

      assert length(comments) == 1
      comment = comments |> Enum.at(0)
      assert length(comment.replies) == 2
    end
  end
end
