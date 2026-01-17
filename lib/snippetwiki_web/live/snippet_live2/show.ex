defmodule SnippetwikiWeb.SnippetLive2.Show do
  use SnippetwikiWeb, :live_component

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <div class="card bg-base-100">
      <%= if @editing do %>
        <.form for={@form} class="card-body" phx-change="validate" phx-submit="save_changes" phx-target={@myself}>
          <div class="flex justify-between items-center mb-2 h-14">
            <%= if is_nil(@snippet.content) or @snippet.content_type == "text/html" do %>
              <.input type="text" field={@form[:title]} class="input input-lg" />
            <% else %>
              <div class="text-3xl max-w-[25ch] truncate">{@snippet.title}</div>
            <% end %>

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

          <%= if is_nil(@snippet.content_type) or @snippet.content_type == "text/html" do %>
            <.input field={@form[:content]} type="textarea" />
            <div id={if @snippet.id do "editor-#{@snippet.id}" else "editor-new" end} phx-hook="BlockNote" phx-update="ignore"></div>
          <% end %>

          <%= if @snippet.content_type == "image/jpeg" do %>
            <img src={get_file_url(@snippet.title)} alt={@snippet.title}>
          <% end %>
        </.form>
      <% else %>
        <div class="card-body">
          <div class="flex justify-between items-center mb-2 h-14">
            <div class="text-3xl max-w-[25ch] truncate">{@snippet.title}</div>
            <div>
              <%= unless String.starts_with?(@snippet.title, "Talk:") do %>
                <.button phx-click="talk_page" phx-value-id={@snippet.id}>
                  <.icon name="hero-chat-bubble-left-right" />
                </.button>
              <% end %>
              <%= if @snippet.has_draft do %>
                <.button phx-click="edit_snippet" phx-target={@myself} variant="warning">
                  <.icon name="hero-pencil" />
                </.button>
              <% else %>
                <.button phx-click="edit_snippet" phx-target={@myself}>
                  <.icon name="hero-pencil" />
                </.button>
              <% end %>
              <.button phx-click="close_snippet" phx-value-id={@snippet.id}>
                <.icon name="hero-x-mark" />
              </.button>
            </div>
          </div>

          <%= if is_nil(@snippet.content) do %>
            <div class="flex items-center justify-center p-12">
                <p class="text-center text-base-content/50">Empty snippet</p>
              </div>
          <% else %>
            <%= if @snippet.content_type == "text/html" do %>
              <textarea class="hidden">{@snippet.content}</textarea>
              <div id={"viewer-#{@snippet.id}"} phx-hook="BlockNote" phx-update="ignore"></div>
            <% end %>

            <%= if @snippet.content_type == "image/jpeg" do %>
              <img src={get_file_url(@snippet.title)} alt={@snippet.title}>
            <% end %>
          <% end %>

          <div class="flex items-center gap-6 mt-2">
              <div class="flex items-center gap-2">
                <.icon name="hero-eye" />
                <div id={"views-#{@snippet.id}"} phx-hook="Number" data-number={@snippet.views} phx-update="ignore"></div>
              </div>
              <button class="btn" phx-click="like_snippet" phx-target={@myself}>
                <.icon name="hero-hand-thumb-up" />
                <div id={"likes-#{@snippet.id}"} phx-hook="Number" data-number={@snippet.like_count} phx-update="ignore"></div>
              </button>
          </div>
        </div>
      <% end %>
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
    {:ok, _} = Snippets.like_snippet(socket.assigns.current_scope, socket.assigns.snippet)
    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_snippet", _, socket) do
    snippet = socket.assigns.snippet
    {:ok, _} = Snippets.create_draft(socket.assigns.current_scope, snippet)

    {:noreply,
      socket
      |> assign(:editing, true)
      |> assign(:form, to_form(Snippets.change_snippet(socket.assigns.current_scope, snippet)))}
  end

  @impl true
  def handle_event("validate", %{"snippet" => snippet_params}, socket) do
    changeset = Snippets.change_snippet(socket.assigns.current_scope, socket.assigns.snippet, snippet_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save_changes", %{"snippet" => %{"title" => title, "content" => content}}, socket) do
    case Snippets.create_new_revision(socket.assigns.current_scope, socket.assigns.snippet, %{"title" => title, "has_draft" => false}, content) do
      {:ok, snippet} ->
        {:noreply,
        socket
        |> assign(:editing, false)
        |> assign(:snippet, snippet)
        |> put_flash(:info, "Snippet updated successfully")}

      # {:error, %Ecto.Changeset{} = changeset} ->
      #   {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("discard_changes", _, socket) do
    {:ok, _} = Snippets.discard_draft(socket.assigns.current_scope, socket.assigns.snippet)
    {:noreply, assign(socket, :editing, false)}
  end

  @impl true
  def handle_event("delete", _, socket) do
    {:ok, _} = Snippets.delete_snippet(socket.assigns.current_scope, socket.assigns.snippet)

    {:noreply, socket}
  end

  defp get_file_url(title) do
    "/files/" <> String.replace_prefix(title, "File:", "")
  end
end
