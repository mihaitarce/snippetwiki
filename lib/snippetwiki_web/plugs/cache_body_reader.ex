defmodule SnippetwikiWeb.Plugs.CacheBodyReader do
  @moduledoc """
  A `Plug.Parsers` body reader that stashes the raw request body in
  `conn.assigns.raw_body` while the parsers consume it, so the WikiRag
  proxy can forward the original bytes upstream.
  """

  def read_body(conn, opts) do
    case Plug.Conn.read_body(conn, opts) do
      {:ok, chunk, conn} -> {:ok, chunk, cache(conn, chunk)}
      {:more, chunk, conn} -> {:more, chunk, cache(conn, chunk)}
      {:error, _} = error -> error
    end
  end

  defp cache(conn, chunk) do
    Plug.Conn.assign(conn, :raw_body, (conn.assigns[:raw_body] || "") <> chunk)
  end
end
