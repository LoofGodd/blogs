defmodule Loofgodd.Blog.LikeTest do
  use Loofgodd.DataCase
  use Timex

  import Loofgodd.Blog.BlogFixtures
  import Loofgodd.AccountsFixtures
  alias Loofgodd.Blog.{Like, Post}
  alias Loofgodd.Repo
  alias Loofgodd.Accounts

  describe "toggle/1" do
    setup do
      role_fixture()
      user = user_fixture()
      post = post_fixture()

      {:ok, user: user, post: post}
    end

    test "toggles like for a post by a user", %{user: user, post: post} do
      attrs = %{post_id: post.id, user_id: user.id}

      assert {:ok, _like} = Like.toggle(attrs)
      assert Post.count_likes(post) == 1

      assert {:ok} = Like.toggle(attrs)
      assert Post.count_likes(post) == 0
    end
  end

  defp seed_likes(post, user_ids) do
    user_ids
    |> Enum.each(fn user_id ->
      %{post_id: post.id, user_id: user_id, updated_at: post.published_at}
      |> Like.toggle()
    end)
  end

  describe "top_posts_by_period/2" do
    setup do
      now = DateTime.utc_now() |> DateTime.truncate(:second)
      role_fixture()
      user_fixture()

      for _ <- 1..20 do
        user_fixture()
      end

      # helper to shift “now” by i units of period
      ts = fn
        "day" -> Timex.beginning_of_day(now)
        "week" -> Timex.beginning_of_week(now, :sun)
        "month" -> Timex.beginning_of_month(now)
        "year" -> Timex.beginning_of_year(now)
      end

      # generate 5 posts per period, each with its own timestamp
      posts_day =
        for i <- 1..5 do
          post_fixture(%{
            title: "day_post_#{i}",
            published_at: ts.("day")
          })
        end

      posts_week =
        for i <- 1..5 do
          post_fixture(%{
            title: "week_post_#{i}",
            published_at: ts.("week")
          })
        end

      posts_month =
        for i <- 1..5 do
          post_fixture(%{
            title: "month_post_#{i}",
            published_at: ts.("month")
          })
        end

      posts_year =
        for i <- 1..5 do
          post_fixture(%{
            title: "year_post_#{i}",
            published_at: ts.("year")
          })
        end

      # now seed likes: more recent buckets get more likes
      seed_likes(Enum.at(posts_day, 0), 1..20)
      seed_likes(Enum.at(posts_week, 0), 1..15)
      seed_likes(Enum.at(posts_month, 0), 1..10)
      seed_likes(Enum.at(posts_year, 0), 1..5)

      posts = posts_day ++ posts_month ++ posts_year

      {:ok, posts: posts}
    end

    test "with day/week/month/year" do
      periods = ["day", "week", "month", "year"]
      expected_lengths = [1, 2, 3, 4]

      results =
        Enum.map(periods, &Post.top_posts_by_period/1)
        |> Enum.zip(expected_lengths)

      Enum.each(results, fn {posts, expected_length} ->
        assert length(posts) == expected_length
      end)

      invalid_periods = [
        {"no valid period", nil},
        {"no valid period", "5"},
        {"day", "5"}
      ]

      Enum.each(invalid_periods, fn
        {period, nil} ->
          assert_raise ArgumentError, fn ->
            Post.top_posts_by_period(period)
          end

        {period, limit} ->
          assert_raise ArgumentError, fn ->
            Post.top_posts_by_period(period, limit)
          end
      end)
    end

    test "like_post_by_user/2" do
      expect_user_id_and_total_posts = [{1, 4}, {6, 3}, {11, 2}, {16, 1}]

      Enum.each(expect_user_id_and_total_posts, fn {user_id, total_user_like_post} ->
        assert length(Post.likes_post_by_user(user_id)) == total_user_like_post
      end)
    end
  end
end
