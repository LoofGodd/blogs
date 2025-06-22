defmodule Loofgodd.Blog do
  alias Loofgodd.Repo
  alias Loofgodd.Blog.{Post, PostRevision, Tag}

  def upsert_blog(post, attrs) do
    tag_names =
      attrs
      |> Map.get(:tag_names, "")
      |> String.split(:binary.compile_pattern([" ", ",", "-"]), trim: true)

    Repo.transact(fn ->
      with {:ok, post} <- Post.upsert(post, attrs),
           {:ok, _} <- PostRevision.create(post, attrs),
           {:ok, _} <- Tag.insert_all(post, tag_names) do
        {:ok, post}
      end
    end)
  end
end
