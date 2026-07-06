defmodule SnippetwikiWeb.FileController do
  use SnippetwikiWeb, :controller

  alias Snippetwiki.Snippets

  def download(conn, %{"title" => [title | _]}) do
    snippet = Snippets.load_snippet!(conn.assigns.current_scope, title, "File")
    send_download(conn, {:binary, snippet.content}, filename: title, disposition: :inline)
  end

  def upload(conn, %{"file" => upload}) do
    snippet_result =
      if is_nil(Snippets.find_snippet(conn.assigns.current_scope, upload.filename, "File")) do
        Snippets.create_snippet(conn.assigns.current_scope, %{ title: upload.filename, namespace: "File" })
      else
        filename = Snippets.Snippet.create_unique_filename(upload.filename)
        Snippets.create_snippet(conn.assigns.current_scope, %{ title: filename, namespace: "File" })
      end

    with {:ok, snippet} <- snippet_result,
         {:ok, content} <- File.read(upload.path),
         {:ok, _updated_snippet} <- Snippets.create_new_revision(conn.assigns.current_scope, snippet, %{}, content, upload.content_type) do
      json(conn, %{data: %{url: snippet.title}})
    else
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Unable to upload file"})
    end
  end
end
