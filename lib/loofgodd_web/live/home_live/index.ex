defmodule LoofgoddWeb.HomeLive.Index do
  use LoofgoddWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Home")}
  end
end
