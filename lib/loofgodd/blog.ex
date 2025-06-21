defmodule Loofgodd.Blog do
  alias Loofgodd.Repo
  alias Loofgodd.Blog.{Post, PostRevision, Tag}

  def create_blog(attrs, user_id) do
    tag_names =
      attrs
      |> Map.get(:tag_names, "")
      |> String.split(:binary.compile_pattern([" ", ",", "-"]), trim: true)

    Repo.transact(fn ->
      with {:ok, post} <- Post.create(attrs, user_id),
           {:ok, _} <- PostRevision.create(post, attrs),
           {:ok, _} <- Tag.insert_all(post, tag_names) do
        {:ok, post}
      end
    end)
  end
end
