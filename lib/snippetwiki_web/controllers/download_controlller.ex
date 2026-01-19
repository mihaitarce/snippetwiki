defmodule SnippetwikiWeb.DownloadController do
  use SnippetwikiWeb, :controller

  alias Snippetwiki.Snippets

  def download(conn, %{"title" => [title | _]}) do
    snippet = Snippets.find_snippet!(conn.assigns.current_scope, title, "File")
    send_download(conn, {:binary, snippet.content}, filename: title, disposition: :inline)
  end
end
