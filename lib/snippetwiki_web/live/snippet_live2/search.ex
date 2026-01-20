defmodule SnippetwikiWeb.SnippetLive2.Search do
  use SnippetwikiWeb, :live_component

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <form class="dropdown dropdown-end w-full">
        <label tabIndex={0} role="button" class="input w-full">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                  stroke="currentColor"
                  class="h-[1em] opacity-50">
                <path strokeLinecap="round" strokeLinejoin="round"
                      d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"/>
            </svg>
            <input name="query" type="search" class="grow" placeholder="Search"
                   phx-change="search" phx-target={@myself} phx-debounce="200" />
        </label>
        <ul tabIndex={-1} class="dropdown-content bg-base-100 rounded-box shadow-sm z-1 p-2 mt-3 w-full text-base-content/70">
          <%= if Enum.empty?(@results) do %>
            <div class="text-base-content/50 italic px-2">No matches found</div>
          <% else %>
            <li :for={result <- @results} id={"search-result-#{result.id}"}
              class="px-2 py-1 truncate hover:bg-primary-content/70 hover:text-primary/70"
              phx-click="open_snippet" phx-value-id={result.id}>
              <a>{result.title}</a>
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
     |> assign(:current_scope, assigns.current_scope)
     |> assign(:results, Snippets.search_snippets(assigns.current_scope))}
  end

  @impl true
  def handle_event("search", %{ "query" => query }, socket) do
    IO.inspect(query)
    {:noreply,
     socket
     |> assign(:results, Snippets.search_snippets(socket.assigns.current_scope, query))}
  end
end
