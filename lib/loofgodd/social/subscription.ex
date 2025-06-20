defmodule Loofgodd.Social.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscriptions" do

    field :user_id, :id
    field :author_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [])
    |> validate_required([])
  end
end
