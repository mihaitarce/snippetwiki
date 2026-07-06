defmodule SnippetwikiWeb.Plugs.AllowedHosts do
  @moduledoc """
  Rejects HTTP requests whose Host header is not in `:allowed_hosts`.

  Empty list allows all hosts (WikiRag-compatible `ALLOWED_HOSTS` behavior).
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case Application.get_env(:snippetwiki, :allowed_hosts, []) do
      [] ->
        conn

      allowed ->
        host = host_without_port(conn.host || "")

        if host in allowed do
          conn
        else
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(403, Jason.encode!(%{error: "Forbidden"}))
          |> halt()
        end
    end
  end

  defp host_without_port(host) do
    host
    |> String.downcase()
    |> String.split(":")
    |> hd()
  end
end
