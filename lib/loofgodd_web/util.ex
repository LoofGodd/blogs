defmodule LoofgoddWeb.Util do
  def on_mount(:save_request_uri, _params, _session, socket) do
    {:cont,
     Phoenix.LiveView.attach_hook(
       socket,
       :save_request_path,
       :handle_params,
       &save_request_path/3
     )}
  end

  defp save_request_path(_params, uri, socket) do
    {:cont, Phoenix.Component.assign(socket, :current_uri, URI.parse(uri) |> Map.get(:path))}
  end
end
