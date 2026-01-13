defmodule SnippetwikiWeb.SnippetLive.Show do
  use SnippetwikiWeb, :live_component

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <div id={"card" <> Integer.to_string(@snippet.id)} class="card bg-base-100">
      <div class="card-body">
        <%= if @editing do %>
          <.form for={@form} phx-submit="save_changes" phx-target={@myself}>
            <div class="flex justify-between items-center mb-2">
              <%!-- <.svelte name="InputField" props={%{ --%>
                  <%!-- room: @snippet.id --%>
                <%!-- }} /> --%>
              <.input type="text" field={@form[:title]} class="hidden" />

              <div>
                <.button type="button"
                  phx-click="delete"
                  phx-target={@myself}
                  data-confirm="Are you sure?">
                  <.icon name="hero-trash" />
                </.button>
                <.button type="submit">
                  <.icon name="hero-check" />
                </.button>
                <.button type="button" phx-click="discard_changes" phx-target={@myself}>
                  <.icon name="hero-x-mark" />
                </.button>
              </div>
            </div>

            <%!-- <.svelte name="Editor" props={%{ --%>
                  <%!-- room: @snippet.id, --%>
                <%!-- }} /> --%>
            <.input type="textarea" field={@form[:content]} class="hidden" />
          </.form>
        <% else %>
          <div class="flex justify-between items-center mb-2">
            <div class="text-3xl">{@snippet.title}</div>
            <div>
              <.button>
                <.icon name="hero-chat-bubble-left-right" />
              </.button>
              <.button phx-click="edit_snippet" phx-target={@myself}>
                <.icon name="hero-pencil" />
              </.button>
              <.button phx-click="close_snippet" phx-value-id={@snippet.id}>
                <.icon name="hero-x-mark" />
              </.button>
            </div>
          </div>

          <article class="prose">
            <%= if @latest_revision do %>
                {@latest_revision.content}
            <% else %>
                <div class="flex items-center justify-center p-12">
                  <p class="text-center text-base-content/50">Empty snippet</p>
                </div>
            <% end %>
          </article>

          <%!-- <.svelte name="SnippetStats" props={%{ --%>
              <%!-- views: @snippet.views, --%>
              <%!-- likes: length(@snippet.likes) --%>
            <%!-- }} /> --%>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :editing, false)}
  end

  @impl true
  def update(assigns, socket) do
    snippet = assigns.snippet
    {:ok,
     socket
     |> assign(:snippet, snippet)
     |> assign(:form, to_form(Snippets.change_snippet(snippet)))
     |> assign(:latest_revision, Snippets.get_latest_revision!(snippet))}
  end

  @impl true
  def handle_event("edit_snippet", _, socket) do
    snippet = socket.assigns.snippet
    case snippet.has_draft do
      true ->
        {:ok, snippet} = Snippets.update_snippet(snippet, %{has_draft: true})
        {:noreply,
          socket
          |> assign(:editing, true)
          |> assign(:snippet, snippet)}
      false ->
        {:noreply,
          socket
          |> assign(:editing, true)}
    end
  end

  @impl true
  def handle_event("save_changes", %{"snippet" => %{"title" => title, "content" => content}}, socket) do
    IO.inspect("Saving #{title}: #{content}")
    snippet = socket.assigns.snippet
    {:ok, snippet} = Snippets.update_snippet(snippet, %{"title" => title, "has_draft" => false})
    {:noreply,
     socket
     |> assign(:editing, false)
     |> assign(:snippet, snippet)
    }
  end

  @impl true
  def handle_event("discard_changes", _, socket) do
    {:noreply, assign(socket, :editing, false)}
  end

  @impl true
  def handle_event("delete", _, socket) do
    {:ok, _} = Snippets.delete_snippet(socket.assigns.snippet)

    {:noreply, socket}
  end
end
