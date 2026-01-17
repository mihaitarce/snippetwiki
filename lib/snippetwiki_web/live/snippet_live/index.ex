defmodule SnippetwikiWeb.SnippetLive.Index do
  use SnippetwikiWeb, :live_view

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
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
        <:col :let={{_id, snippet}} label="Has draft">{snippet.has_draft}</:col>
        <:col :let={{_id, snippet}} label="Views">{snippet.views}</:col>
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
    if connected?(socket) do
      Snippets.subscribe_snippets(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Snippets")
     |> stream(:snippets, list_snippets(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    snippet = Snippets.get_snippet!(socket.assigns.current_scope, id)
    {:ok, _} = Snippets.delete_snippet(socket.assigns.current_scope, snippet)

    {:noreply, stream_delete(socket, :snippets, snippet)}
  end

  @impl true
  def handle_info({type, %Snippetwiki.Snippets.Snippet{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :snippets, list_snippets(socket.assigns.current_scope), reset: true)}
  end

  defp list_snippets(current_scope) do
    Snippets.list_snippets(current_scope)
  end
end
