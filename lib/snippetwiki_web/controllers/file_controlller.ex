defmodule SnippetwikiWeb.FileController do
  use SnippetwikiWeb, :controller

  alias Snippetwiki.Snippets

  def download(conn, %{"title" => [title | _]}) do
    snippet = Snippets.find_snippet!(conn.assigns.current_scope, title, "File")
    send_download(conn, {:binary, snippet.content}, filename: title, disposition: :inline)
  end

  def upload(conn, %{"file" => upload}) do
    snippet = Snippets.find_snippet(conn.assigns.current_scope, upload.filename, "File")

    if is_nil(snippet) do
      {:ok, snippet} = Snippets.create_snippet(conn.assigns.current_scope, %{ title: upload.filename, namespace: "File" })
      {:ok, content} = File.read(upload.path)
      Snippets.create_new_revision(conn.assigns.current_scope, snippet, %{}, content, upload.content_type)

      IO.inspect upload.filename

      json(conn, %{data: %{url: upload.filename}})
    else
      # Already exists, generate unique name
      conn
      |> put_status(403)
      |> put_view(html: SnippetwikiWeb.ErrorHTML, json: SnippetwikiWeb.ErrorJSON)
      |> render(:"403")
    end
  end
end
