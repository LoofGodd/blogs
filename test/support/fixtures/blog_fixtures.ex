defmodule Loofgodd.Blog.BlogFixtures do
  use Loofgodd.DataCase

  def post_valid_attributes(attrs \\ %{}) do
    %{
      title: "Test Post",
      content:
        ~s({"type":"doc","content":[{"type":"paragraph","content":[{"type":"text","text":"Hello"}]}]}),
      status: "published",
      tag_names: "Elixir, Phoenix",
      revision_note: "Initial draft",
      published_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }
    |> Map.merge(attrs)
  end

  def post_fixture(attrs \\ %{}) do
    attrs =
      %{user_id: 1}
      |> Map.merge(post_valid_attributes(attrs))

    {:ok, post} = Loofgodd.Blog.upsert_blog(%Loofgodd.Blog.Post{}, attrs)
    post
  end
end
