defmodule Loofgodd.Repo do
  use Ecto.Repo,
    otp_app: :loofgodd,
    adapter: Ecto.Adapters.Postgres
end
