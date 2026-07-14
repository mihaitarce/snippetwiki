defmodule SnippetwikiWeb.SearchComponent do
  @moduledoc """
  Instant title search with a results dropdown.

  NOTE: currently unwired — the header slot it occupied was removed in favor
  of the WikiRag Ask panel. Kept for reuse if local title search returns;
  emits `open_snippet` to the parent LiveView when a result is clicked.
  """
  use SnippetwikiWeb, :live_component

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <form id={@id} class="dropdown w-full" onsubmit="event.preventDefault()">
      <label tabindex="0" role="button" class="input input-sm sm:input-md w-full">
        <.icon name="hero-magnifying-glass" class="size-4 shrink-0 opacity-50" />
        <input
          name="query"
          type="search"
          class="grow min-w-0"
          placeholder="Search articles…"
          autocomplete="off"
          phx-change="search"
          phx-target={@myself}
          phx-debounce="200"
        />
      </label>
      <ul
        tabindex="-1"
        class="dropdown-content menu z-40 mt-2 w-full rounded-box border border-base-300/60 bg-base-100 p-2 shadow-lg"
      >
        <%= if Enum.empty?(@results) do %>
          <li class="pointer-events-none px-2 py-1 italic text-base-content/50">No matches found</li>
        <% else %>
          <li :for={result <- @results} id={"search-result-#{result.id}"}>
            <button
              type="button"
              class="truncate rounded-field px-2 py-1.5 text-left transition-colors hover:bg-base-200 hover:text-primary"
              phx-click={
                JS.push("open_snippet", value: %{id: to_string(result.id)})
                |> JS.dispatch("blur")
              }
            >
              {result.title}
            </button>
          </li>
        <% end %>
      </ul>
    </form>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:id, assigns.id)
     |> assign(:current_scope, assigns.current_scope)
     |> assign(:results, [])}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    if String.length(query) > 0 do
      {:noreply,
       assign(socket, :results, Snippets.search_snippets(socket.assigns.current_scope, query))}
    else
      {:noreply, assign(socket, :results, [])}
    end
  end
end
