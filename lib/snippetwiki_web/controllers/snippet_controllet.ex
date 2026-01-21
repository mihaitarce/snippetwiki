defmodule SnippetwikiWeb.SnippetController do
  use SnippetwikiWeb, :controller

  alias Snippetwiki.Snippets

  def index(conn, _) do
    snippets = Snippets.search_snippets(conn.assigns.current_scope)

    results = Enum.map(snippets, fn s -> %{ id: s.id, title: s.title } end)

    json(conn, %{data: %{snippets: results}})
  end
end
