defmodule Loofgodd.Repo do
  use Ecto.Repo,
    otp_app: :loofgodd,
    adapter: Ecto.Adapters.SQLite3
end
