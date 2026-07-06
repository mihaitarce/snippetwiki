defmodule SnippetwikiWeb.SnippetComponent do
  use SnippetwikiWeb, :live_component

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <div class="card bg-base-100" id={"snippet-#{@snippet.id}"}>
      <%= if @editing do %>
        <.form for={@form} class="card-body z-1 p-4 sm:p-6" phx-change="validate" phx-submit="save_changes" phx-target={@myself}>
          <div class="flex justify-between gap-2 items-start relative z-10">
            <%= if @new_snippet and is_nil(@snippet.namespace) do %>
              <div class="flex flex-col gap-2 min-w-0 flex-1 [&_.fieldset]:mb-0">
                <.input id={"title-#{@snippet.id}"} type="text" field={@form[:title]} class="title text-2xl input input-lg w-full min-w-0" />
                <div class="flex items-center gap-2">
                  <span class="text-sm text-base-content/60 shrink-0">Save to</span>
                  <.bag_indicator
                    bag={@snippet.bag}
                    snippet_id={@snippet.id}
                    selectable={length(@current_scope.user.bags) > 1}
                    bags={@current_scope.user.bags}
                    myself={@myself}
                  />
                </div>
              </div>
            <% else %>
              <div class="min-w-0 flex-1 [&_.fieldset]:mb-0">
                <%= if is_nil(@snippet.namespace) do %>
                  <.input id={"title-#{@snippet.id}"} type="text" field={@form[:title]} class="title text-2xl input input-lg w-full min-w-0" />
                <% else %>
                  <h1 class="text-2xl sm:text-3xl truncate min-w-0 leading-tight" title={@snippet.title}>{@snippet.namespace}:{@snippet.title}</h1>
                <% end %>
              </div>
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
        <div class="card-body p-4 sm:p-6">
          <div class="flex justify-between gap-2 items-start">
            <div class="min-w-0 flex-1">
              <%= if @snippet.namespace do %>
                <h1 class="text-2xl sm:text-3xl leading-tight break-words" title={@snippet.title}>
                  {@snippet.namespace}:{@snippet.title}<.bag_indicator inline bag={@snippet.bag} snippet_id={@snippet.id} />
                </h1>
              <% else %>
                <h1 class="text-2xl sm:text-3xl leading-tight break-words">
                  {@snippet.title}<.bag_indicator inline bag={@snippet.bag} snippet_id={@snippet.id} />
                </h1>
              <% end %>
            </div>
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
    was_editing = Map.get(socket.assigns, :editing, false)
    prior_snippet_id = get_in(socket.assigns, [:snippet, Access.key(:id)])

    socket =
      socket
      |> assign(:snippet, assigns.snippet)
      |> assign(:current_scope, assigns.current_scope)
      |> assign(:editing, assigns.editing)
      |> assign(:new_snippet, Map.get(assigns, :new_snippet, false))

    needs_form =
      assigns.editing &&
        (!was_editing || prior_snippet_id != assigns.snippet.id || is_nil(socket.assigns[:form]))

    socket =
      if needs_form do
        assign(socket, :form, to_form(Snippets.change_snippet(assigns.current_scope, assigns.snippet)))
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_event("like_snippet", _, socket) do
    {:ok, _} = Snippets.like_snippet(socket.assigns.current_scope, socket.assigns.snippet)
    {:noreply, socket}
  end

  @impl true
  def handle_event("change_bag", %{"snippet" => %{"bag" => bag}}, socket) do
    if socket.assigns.snippet.bag == bag do
      {:noreply, socket}
    else
      case Snippets.update_snippet(
             socket.assigns.current_scope,
             socket.assigns.snippet,
             %{"bag" => bag}
           ) do
        {:ok, snippet} ->
          {:noreply, assign(socket, :snippet, snippet)}

        {:error, %Ecto.Changeset{} = changeset} ->
          message =
            changeset
            |> Ecto.Changeset.traverse_errors(fn {msg, _opts} -> msg end)
            |> Enum.map_join("; ", fn {field, errors} ->
              "#{field} #{Enum.join(errors, ", ")}"
            end)

          {:noreply, put_flash(socket, :error, "Could not change bag: #{message}")}
      end
    end
  end

  @impl true
  def handle_event("validate", %{"snippet" => snippet_params}, socket) do
    changeset =
      Snippets.change_snippet(socket.assigns.current_scope, socket.assigns.snippet, snippet_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save_changes", %{"snippet" => snippet_params}, socket) do
    attrs =
      snippet_params
      |> Map.take(["title", "bag"])
      |> Map.put("has_draft", false)

    content = Map.get(snippet_params, "content")

    {:ok, snippet} =
      Snippets.create_new_revision(
        socket.assigns.current_scope,
        socket.assigns.snippet,
        attrs,
        content
      )
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

  attr :inline, :boolean, default: false
  attr :bag, :string, required: true
  attr :snippet_id, :integer, required: true
  attr :selectable, :boolean, default: false
  attr :bags, :list, default: []
  attr :myself, :any, default: nil

  defp bag_indicator(assigns) do
    ~H"""
    <%= if @selectable do %>
      <select
        id={"bag-#{@snippet_id}"}
        name="snippet[bag]"
        phx-change="change_bag"
        phx-target={@myself}
        aria-label="Save to bag"
        title="The collection this article will be saved to"
        class="select select-sm select-bordered w-fit shrink-0 h-9 min-h-9 py-0 pl-2 pr-7 text-sm font-medium field-sizing-content"
      >
        <%= for {label, value} <- bag_options(@bags) do %>
          <option value={value} selected={value == @bag}>{label}</option>
        <% end %>
      </select>
    <% else %>
      <span
        class={[
          "badge badge-outline badge-sm font-medium",
          @inline && "inline-flex align-middle ml-2",
          !@inline && "shrink-0"
        ]}
        title="The collection this article belongs to"
      >{@bag}</span>
    <% end %>
    """
  end

  defp bag_options(bags) do
    Enum.map(bags, fn bag -> {bag, bag} end)
  end
end
