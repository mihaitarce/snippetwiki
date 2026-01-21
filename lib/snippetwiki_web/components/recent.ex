defmodule SnippetwikiWeb.RecentComponent do
  use SnippetwikiWeb, :live_component

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <ul>
        <li :for={snippet <- Enum.filter(@snippets, fn s -> is_nil(s.namespace) end)}
              id={"recent-link-#{Integer.to_string(snippet.id)}"} class="pb-1">
            <a phx-click="open_snippet" phx-value-id={snippet.id}>{snippet.title}</a>
            <%= if snippet.has_draft do %>
              <.icon name="hero-pencil" class="size-4 ms-2" />
            <% end %>
            <%= if snippet.id in @open do %>
              <span class="cursor-pointer" phx-click="close_snippet" phx-value-id={snippet.id}>
                <.icon name="hero-x-mark" class="size-4 ms-2" />
              </span>
            <% end %>
          </li>
      </ul>

      <div class="mt-4">
        <button type="button" class="btn" phx-click="close_snippets">
          <.icon name="hero-x-mark" />
          Close all
        </button>
      </div>
    </div>
    """
  end
end
