defmodule SnippetwikiWeb.SnippetComponent do
  use SnippetwikiWeb, :live_component

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <div class="card bg-base-100" id={"snippet-#{@snippet.id}"}>
      <%= if @editing do %>
        <.form for={@form} class="card-body z-1" phx-change="validate" phx-submit="save_changes" phx-target={@myself}>
          <div class="flex justify-between gap-2 min-h-16">
            <%= if is_nil(@snippet.namespace) do %>
              <.input id={"title-#{@snippet.id}"} type="text" field={@form[:title]} class="title text-2xl input input-lg w-full" />
            <% else %>
              <h1 class="text-3xl truncate py-1.5" title={@snippet.title}>{@snippet.namespace}:{@snippet.title}</h1>
            <% end %>

            <div class="flex flex-col-reverse sm:flex-row gap-1 py-1">
              <.button type="button" variant="error"
                phx-click="delete"
                phx-target={@myself}
                data-confirm="Are you sure? This action cannot be undone.">
                <.icon name="hero-trash" class="size-6" />
              </.button>

              <%= if is_nil(@snippet.namespace) do %>
                <.button type="submit" variant="success">
                  <.icon name="hero-check" class="size-7" />
                </.button>
                <%!-- <.button phx-disable-with="Saving..." variant="primary">Save Snippet</.button> --%>
              <% end %>

              <.button type="button" phx-click="discard_changes" phx-target={@myself}>
                <.icon name="hero-x-mark" class="size-7" />
              </.button>
              <%!-- <.button navigate={return_path(@return_to, @snippet)}>Cancel</.button> --%>
            </div>
          </div>

          <%= if is_nil(@snippet.content_type) or @snippet.content_type == "application/vnd.blocknote+json" do %>
            <.input id={"content-#{@snippet.id}"} field={@form[:content]} type="textarea" />
            <div id={"editor-#{@snippet.id}"} phx-hook="Editor" phx-update="ignore"
                 data-id={@snippet.id} data-username={@current_scope.user.email}></div>
            <div class="text-lg text-base-content/30">Type '/' for commands, '[' for linking to other articles.</div>
          <% end %>

          <%= if @snippet.content_type == "image/jpeg" do %>
            <img src={get_file_url(@snippet.title)} alt={@snippet.title}>
          <% end %>

          <%= if @snippet.content_type == "application/pdf" do %>
            <iframe src={get_file_url(@snippet.title)} title={@snippet.title} class="w-full aspect-square"></iframe>
          <% end %>
        </.form>
      <% else %>
        <div class="card-body">
          <div class="flex justify-between gap-2 min-h-16">
            <%= if @snippet.namespace do %>
              <h1 class="text-3xl truncate py-1.5" title={@snippet.title}>{@snippet.namespace}:{@snippet.title}</h1>
            <% else %>
              <h1 class="text-3xl py-1.5">{@snippet.title}</h1>
            <% end %>
            <div class="flex flex-col-reverse justify-end sm:flex-row gap-1 py-1">
              <%= if is_nil(@snippet.namespace) do %>
                <%!-- <.button phx-click="talk_page" phx-value-title={@snippet.title}>
                  <.icon name="hero-chat-bubble-left-right" class="size-6" />
                </.button> --%>
              <% end %>

              <%= if @snippet.namespace == "File" do %>
                <a href={~p"/files/#{@snippet.title}"} target="_blank"
                   class="btn btn-ghost btn-square btn-soft btn-primary">
                  <.icon name="hero-arrow-down-tray" class="size-6" />
                </a>
              <% end %>

              <%= if is_nil(@snippet.namespace) or @snippet.namespace == "File" do %>
                <%= if @snippet.has_draft do %>
                  <.button phx-click="edit_snippet" phx-value-id={@snippet.id} variant="warning"
                           title="Someone has started editing this snippet.">
                    <.icon name="hero-pencil" class="size-6" />
                  </.button>
                <% else %>
                  <.button phx-click="edit_snippet" phx-value-id={@snippet.id}>
                    <.icon name="hero-pencil" class="size-6" />
                  </.button>
                <% end %>
              <% end %>

              <.button phx-click="close_snippet" phx-value-id={@snippet.id}>
                <.icon name="hero-x-mark" class="size-7" />
              </.button>
            </div>
          </div>

          <%= if is_nil(@snippet.content) do %>
            <div class="flex items-center justify-center p-10.5">
                <p class="text-lg text-center text-base-content/30">Empty snippet</p>
              </div>
          <% else %>
            <%= if @snippet.content_type == "application/vnd.blocknote+json" do %>
              <textarea class="hidden">{@snippet.content}</textarea>
              <div id={"viewer-#{@snippet.id}"} phx-hook="Viewer" phx-update="ignore"></div>
            <% end %>

            <%= if @snippet.content_type == "image/jpeg" do %>
              <img src={get_file_url(@snippet.title)} alt={@snippet.title}>
            <% end %>

            <%= if @snippet.content_type == "application/pdf" do %>
              <iframe src={get_file_url(@snippet.title)} title={@snippet.title} class="w-full aspect-square"></iframe>
            <% end %>
          <% end %>

          <%= if is_nil(@snippet.namespace) do %>
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
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    socket = socket
      |> assign(:snippet, assigns.snippet)
      |> assign(:current_scope, assigns.current_scope)
      |> assign(:editing, assigns.editing)

    if (assigns.editing) do
      {:ok,
       socket
       |> assign(:form, to_form(Snippets.change_snippet(assigns.current_scope, assigns.snippet)))}
    else
      {:ok, socket}
    end
  end

  @impl true
  def handle_event("like_snippet", _, socket) do
    {:ok, _} = Snippets.like_snippet(socket.assigns.current_scope, socket.assigns.snippet)
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"snippet" => snippet_params}, socket) do
    changeset = Snippets.change_snippet(socket.assigns.current_scope, socket.assigns.snippet, snippet_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save_changes", %{"snippet" => %{"title" => title, "content" => content}}, socket) do
    {:ok, snippet} = Snippets.create_new_revision(socket.assigns.current_scope, socket.assigns.snippet, %{"title" => title, "has_draft" => false}, content)
      # {:error, %Ecto.Changeset{} = changeset} ->
      #   {:noreply, assign(socket, form: to_form(changeset))}

    send(self(), {:stop_editing, snippet})

    {:noreply,
      socket
      |> assign(:snippet, snippet)
      |> put_flash(:info, "Snippet updated successfully")}
  end

  @impl true
  def handle_event("discard_changes", _, socket) do
    {:ok, snippet} = Snippets.discard_draft(socket.assigns.current_scope, socket.assigns.snippet)

    send(self(), {:stop_editing, snippet})

    {:noreply,
     socket
     |> assign(:snippet, snippet)}
  end

  @impl true
  def handle_event("delete", _, socket) do
    {:ok, _} = Snippets.delete_snippet(socket.assigns.current_scope, socket.assigns.snippet)

    {:noreply, socket}
  end

  defp get_file_url(title) do
    prefix_path = Application.get_env(:snippetwiki, SnippetwikiWeb.Endpoint)[:url][:path]
    if prefix_path == "/" do
      "/files/#{title}"
    else
      "#{prefix_path}/files/#{title}"
    end
  end
end
