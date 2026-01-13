defmodule SnippetwikiWeb.SnippetLive.Index do
  use SnippetwikiWeb, :live_view

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Snippets
        <:actions>
          <.button variant="primary" navigate={~p"/snippets/new"}>
            <.icon name="hero-plus" /> New Snippet
          </.button>
        </:actions>
      </.header>

      <.table
        id="snippets"
        rows={@streams.snippets}
        row_click={fn {_id, snippet} -> JS.navigate(~p"/snippets/#{snippet}") end}
      >
        <:col :let={{_id, snippet}} label="Title">{snippet.title}</:col>
        <:action :let={{_id, snippet}}>
          <div class="sr-only">
            <.link navigate={~p"/snippets/#{snippet}"}>Show</.link>
          </div>
          <.link navigate={~p"/snippets/#{snippet}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, snippet}}>
          <.link
            phx-click={JS.push("delete", value: %{id: snippet.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Snippets")
     |> stream(:snippets, list_snippets())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    snippet = Snippets.get_snippet!(id)
    {:ok, _} = Snippets.delete_snippet(snippet)

    {:noreply, stream_delete(socket, :snippets, snippet)}
  end

  defp list_snippets() do
    Snippets.list_snippets()
  end
end
