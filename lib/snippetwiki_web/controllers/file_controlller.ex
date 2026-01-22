defmodule SnippetwikiWeb.FileController do
  use SnippetwikiWeb, :controller

  alias Snippetwiki.Snippets

  def download(conn, %{"title" => [title | _]}) do
    snippet = Snippets.load_snippet!(conn.assigns.current_scope, title, "File")
    send_download(conn, {:binary, snippet.content}, filename: title, disposition: :inline)
  end

  def upload(conn, %{"file" => upload}) do
    snippet = if is_nil(Snippets.find_snippet(conn.assigns.current_scope, upload.filename, "File")) do
      {:ok, snippet} = Snippets.create_snippet(conn.assigns.current_scope, %{ title: upload.filename, namespace: "File" })
      snippet
    else
      filename = Snippets.Snippet.create_unique_filename(upload.filename)

      {:ok, snippet} = Snippets.create_snippet(conn.assigns.current_scope, %{ title: filename, namespace: "File" })
      snippet
    end

    {:ok, content} = File.read(upload.path)
    Snippets.create_new_revision(conn.assigns.current_scope, snippet, %{}, content, upload.content_type)

    json(conn, %{data: %{url: snippet.title}})
  end
end
