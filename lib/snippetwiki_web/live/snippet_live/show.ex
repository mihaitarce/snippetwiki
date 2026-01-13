defmodule SnippetwikiWeb.SnippetLive.Show do
  use SnippetwikiWeb, :live_component

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <div class="card bg-base-100">
      <div class="card-body">
        <%= if @editing do %>
          <.form for={@form} phx-change="validate" phx-submit="save_changes" phx-target={@myself}>
            <div class="flex justify-between items-center mb-2">
              <.input type="text" field={@form[:title]} class="input input-lg" />

              <div>
                <.button type="button" variant="error"
                  phx-click="delete"
                  phx-target={@myself}
                  data-confirm="Are you sure?">
                  <.icon name="hero-trash" />
                </.button>

                <.button type="submit" variant="success">
                  <.icon name="hero-check" />
                </.button>
                <%!-- <.button phx-disable-with="Saving..." variant="primary">Save Snippet</.button> --%>

                <.button type="button" phx-click="discard_changes" phx-target={@myself}>
                  <.icon name="hero-x-mark" />
                </.button>
                <%!-- <.button navigate={return_path(@return_to, @snippet)}>Cancel</.button> --%>
              </div>
            </div>

            <.input type="textarea" field={@form[:content]} class="textarea textarea-lg w-full" rows="10" />
          </.form>
        <% else %>
          <div class="flex justify-between items-center mb-2 h-16">
            <div class="text-3xl">{@snippet.title}</div>
            <div>
              <.button>
                <.icon name="hero-chat-bubble-left-right" />
              </.button>
              <.button phx-click="edit_snippet" phx-target={@myself}>
                <.icon name="hero-pencil" />
              </.button>
              <div :if={@snippet.has_draft} class="badge badge-warning me-2">
              <.icon  name="hero-exclamation-triangle" class="size-[1.25em]" />
              </div>
              <.button phx-click="close_snippet" phx-value-id={@snippet.id}>
                <.icon name="hero-x-mark" />
              </.button>
            </div>
          </div>

          <article class="prose">
            <%= if @snippet.content do %>
                {@snippet.content}
            <% else %>
                <div class="flex items-center justify-center p-12">
                  <p class="text-center text-base-content/50">Empty snippet</p>
                </div>
            <% end %>
          </article>

          <div class="flex items-center gap-6">
              <div>
                  {@snippet.views} views
              </div>
              <button class="btn" phx-click="like_snippet" phx-target={@myself}>
                  {@snippet.like_count} likes
              </button>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:editing, false)}
  end

  @impl true
  def handle_event("like_snippet", _, socket) do
    {:ok, _} = Snippets.like_snippet(socket.assigns.snippet, "me")

    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_snippet", _, socket) do
    snippet = socket.assigns.snippet
    {:ok, _} = Snippets.create_draft(snippet)

    {:noreply,
      socket
      |> assign(:editing, true)
      |> assign(:form, to_form(Snippets.change_snippet(snippet)))}
  end

  @impl true
  def handle_event("validate", %{"snippet" => snippet_params}, socket) do
    changeset = Snippets.change_snippet(socket.assigns.snippet, snippet_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save_changes", %{"snippet" => %{"title" => title, "content" => content}}, socket) do
    case Snippets.create_new_revision(socket.assigns.snippet, %{"title" => title, "has_draft" => false}, content) do
      {:ok, _} ->
        {:noreply,
        socket
        |> assign(:editing, false)
        |> put_flash(:info, "Snippet updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("discard_changes", _, socket) do
    {:ok, _} = Snippets.discard_draft(socket.assigns.snippet)
    {:noreply, assign(socket, :editing, false)}
  end

  @impl true
  def handle_event("delete", _, socket) do
    {:ok, _} = Snippets.delete_snippet(socket.assigns.snippet)

    {:noreply, socket}
  end
end
