defmodule SnippetwikiWeb.ListComponent do
  use SnippetwikiWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <ul>
      <li :for={snippet <- @snippets}
            id={"#{@id}-#{snippet.id}"} class="pb-1">
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
    """
  end
end
