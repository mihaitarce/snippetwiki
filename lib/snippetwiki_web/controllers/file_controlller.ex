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
      filename = create_unique_filename(upload.filename)

      {:ok, snippet} = Snippets.create_snippet(conn.assigns.current_scope, %{ title: filename, namespace: "File" })
      snippet
    end

    {:ok, content} = File.read(upload.path)
    Snippets.create_new_revision(conn.assigns.current_scope, snippet, %{}, content, upload.content_type)

    json(conn, %{data: %{url: upload.filename}})
  end

  defp create_unique_filename(filename) do
    extension = Path.extname(filename)
    basename = Path.basename(filename, extension)

    "#{basename}_#{IO.inspect Enum.to_list(?a..?f) ++ Enum.to_list(?0..?9) |> Enum.take_random(6)}#{extension}"
  end
end
