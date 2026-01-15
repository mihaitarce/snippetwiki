defmodule SnippetwikiWeb.DownloadController do
  use SnippetwikiWeb, :controller

  alias Snippetwiki.Snippets

  def download(conn, %{"name" => [name | _]}) do
    snippet = Snippets.find_snippet!("File:" <> name)
    send_download(conn, {:binary, snippet.content}, filename: name, disposition: :inline)
  end
end
