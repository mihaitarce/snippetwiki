defmodule SnippetwikiWeb.SnippetWikiLive.Index do
  use SnippetwikiWeb, :live_view

  alias Snippetwiki.Snippets
  alias SnippetwikiWeb.WikiComponents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.wiki flash={@flash}>
      <:header>
        <WikiComponents.wiki_header
          current_scope={@current_scope}
          uploads={@uploads}
          ask_open={@ask_open}
        />
      </:header>

      <div id="wiki-hash-open" phx-hook="WikiHashOpen" data-default-bag={@current_scope.user.bag}>
      </div>

      <WikiComponents.wiki_sidebar
        sidebar_mode={@sidebar_mode}
        mobile_view={@mobile_view}
        toc_groups={toc_groups(@snippets, @current_scope.user.bags)}
        file_groups={file_groups(@snippets, @current_scope.user.bags)}
        recent_groups={recent_by_date(@snippets)}
        expanded_bags={@expanded_bags}
        open={@open}
        open_snippets={open_snippets(@snippets, @open)}
        draft_snippets={open_snippets(@snippets, @drafts -- @open)}
      />

      <div class={[
        "min-h-0 min-w-0 flex-1 flex-col",
        @mobile_view == "articles" && "flex",
        @mobile_view != "articles" && "hidden xl:flex"
      ]}>
        <div id="articles-scroll" class="min-w-0 flex-1 overflow-y-auto overscroll-none">
          <div
            id="article-stream"
            class="mx-auto flex w-full max-w-3xl flex-col gap-3 sm:gap-4 p-3 sm:p-6"
          >
            <%= if length(@uploads.documents.entries) > 0 do %>
              <section phx-drop-target={@uploads.documents.ref}>
                <.upload uploads={@uploads} />
              </section>
            <% end %>

            <%= if length(@open) > 0 do %>
              <div
                :for={
                  snippet <-
                    Enum.filter(
                      Enum.map(@open, fn snippet_id ->
                        Enum.find(@snippets, fn snippet -> snippet_id === snippet.id end)
                      end),
                      fn s -> s != nil end
                    )
                }
                id={"snippet-#{snippet.id}"}
              >
                <.live_component
                  module={SnippetwikiWeb.SnippetComponent}
                  id={snippet.id}
                  current_scope={@current_scope}
                  snippet={Snippets.with_content(snippet)}
                  editing={Enum.member?(@editing, snippet.id)}
                  new_snippet={snippet.id in @new_snippets}
                />
              </div>
            <% end %>

            <%= if length(@uploads.documents.entries) == 0 and length(@open) == 0 and is_nil(@missing_article) do %>
              <div class="card select-none p-6">
                <div class="mx-auto mt-6 flex flex-col items-center gap-12 py-12 text-2xl">
                  <img src={~p(/images/logo.svg)} alt="" class="h-[25vh] grayscale opacity-10" />
                  <div class="text-base-content/30">No open snippets</div>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>

      <WikiComponents.ask_panel
        ask_open={@ask_open}
        mobile_view={@mobile_view}
        wikirag_embed_url={@wikirag_embed_url}
      />

      <WikiComponents.missing_article_modal missing_article={@missing_article} />

      <:bottom>
        <WikiComponents.mobile_nav
          mobile_view={@mobile_view}
          draft_count={length(@drafts -- @open)}
        />
      </:bottom>
    </Layouts.wiki>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Snippets.subscribe_snippets(socket.assigns.current_scope)
    end

    snippets = list_snippets(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(
       page_title: "Snippet Wiki",
       sidebar_mode: "contents",
       ask_open: false,
       mobile_view: "articles",
       bag: nil,
       wikirag_embed_url: wikirag_embed_url(),
       snippets: snippets
     )
     |> assign_new(:open, fn -> [] end)
     |> assign_new(:editing, fn -> [] end)
     |> assign_new(:new_snippets, fn -> [] end)
     |> assign_new(:expanded_bags, fn -> MapSet.new() end)
     |> assign_new(:drafts, fn ->
       snippets
       |> Enum.filter(fn s -> s.has_draft end)
       |> Enum.map(fn s -> s.id end)
     end)
     |> assign_new(:pending_deep_link, fn -> nil end)
     |> assign_new(:missing_article, fn -> nil end)
     |> allow_upload(:documents, accept: ~w(.jpg .jpeg .png .webp .pdf), max_entries: 5)}
  end

  @impl true
  def handle_params(%{"scope" => bag, "title" => title}, _uri, socket) do
    pending = {bag, URI.decode(title)}

    if connected?(socket) do
      {:noreply, socket |> apply_deep_link(pending) |> push_patch(to: ~p"/")}
    else
      {:noreply, assign(socket, :pending_deep_link, pending)}
    end
  end

  def handle_params(%{"scope" => bag}, _uri, socket) do
    scope = socket.assigns.current_scope

    if bag in scope.user.bags do
      {:noreply, assign(socket, :bag, bag)}
    else
      {:noreply,
       socket
       |> put_flash(:error, "Unknown scope.")
       |> push_navigate(to: ~p"/")}
    end
  end

  def handle_params(%{"title" => title}, _uri, socket) do
    bag = socket.assigns.current_scope.user.bag
    pending = {bag, URI.decode(title)}

    if connected?(socket) do
      {:noreply, socket |> apply_deep_link(pending) |> push_patch(to: ~p"/")}
    else
      {:noreply, assign(socket, :pending_deep_link, pending)}
    end
  end

  def handle_params(_params, _uri, socket) do
    socket = assign(socket, bag: nil, pending_deep_link: nil)

    if socket.assigns.open != [] or socket.assigns.missing_article do
      {:noreply, socket}
    else
      {:noreply, maybe_open_welcome(socket)}
    end
  end

  @impl true
  def handle_event("create_missing_snippet", _, socket) do
    {bag, title} = socket.assigns.missing_article

    case Snippets.create_snippet(socket.assigns.current_scope, %{title: title, bag: bag}) do
      {:ok, snippet} ->
        {:noreply,
         socket
         |> assign(:snippets, [snippet | socket.assigns.snippets])
         |> assign(missing_article: nil, bag: bag)
         |> assign(:mobile_view, "articles")
         |> assign(:open, [snippet.id | socket.assigns.open])
         |> assign(:editing, [snippet.id | socket.assigns.editing])
         |> assign(:new_snippets, [snippet.id | socket.assigns.new_snippets])
         |> push_event("scroll", %{id: "snippet-#{snippet.id}"})
         |> push_event("focus", %{id: "title-#{snippet.id}", select: true})}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Unable to create article. Please try again.")}
    end
  end

  @impl true
  def handle_event("dismiss_missing_snippet", _, socket) do
    {:noreply,
     socket
     |> assign(missing_article: nil)
     |> maybe_open_welcome()}
  end

  @impl true
  def handle_event("new_snippet", _, socket) do
    title = find_available_title("New snippet", 1, list_snippets(socket.assigns.current_scope))

    case Snippets.create_snippet(socket.assigns.current_scope, %{title: title}) do
      {:ok, snippet} ->
        {:noreply,
         socket
         |> assign(:snippets, [snippet | socket.assigns.snippets])
         |> assign(:mobile_view, "articles")
         |> assign(:open, [snippet.id | socket.assigns.open])
         |> assign(:editing, [snippet.id | socket.assigns.editing])
         |> assign(:new_snippets, [snippet.id | socket.assigns.new_snippets])
         |> push_event("scroll", %{id: "snippet-#{snippet.id}"})
         |> push_event("focus", %{id: "title-#{snippet.id}", select: true})}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Unable to create snippet. Please try again.")}
    end
  end

  @impl true
  def handle_event("open_initial", params, socket) do
    case open_initial_params(params) do
      nil ->
        {:noreply, socket}

      %{title: raw_title, bag: bag} ->
        title = normalize_open_initial_title(raw_title)
        scope = socket.assigns.current_scope

        case Snippets.find_snippet(scope, title) do
          nil ->
            if bag in scope.user.bags do
              {:noreply, assign(socket, :missing_article, {bag, title})}
            else
              {:noreply, put_flash(socket, :error, "Unknown scope.")}
            end

          snippet ->
            {:noreply,
             socket
             |> assign(:bag, snippet.bag)
             |> open_snippet_card(snippet)}
        end
    end
  end

  @impl true
  def handle_event("open_snippet", %{"id" => id}, socket) do
    snippet = Snippets.get_snippet!(socket.assigns.current_scope, String.to_integer(id))

    {:noreply,
     socket
     |> assign(:expanded_bags, MapSet.put(socket.assigns.expanded_bags, snippet.bag))
     |> open_snippet_card(snippet)}
  end

  @impl true
  def handle_event("edit_snippet", %{"id" => id}, socket) do
    snippet_id = String.to_integer(id)
    snippet = Snippets.get_snippet!(socket.assigns.current_scope, snippet_id)

    if not snippet.has_draft do
      {:ok, _} = Snippets.create_draft(socket.assigns.current_scope, snippet)
    end

    socket =
      socket
      |> assign(:mobile_view, "articles")
      |> assign(:editing, [snippet.id | socket.assigns.editing])

    {:noreply,
     if snippet_id in socket.assigns.open do
       socket
     else
       assign(socket, :open, [snippet.id | socket.assigns.open])
     end
     |> push_event("scroll", %{id: "snippet-#{snippet_id}"})}
  end

  @impl true
  def handle_event("close_snippet", %{"id" => id}, socket) do
    snippet_id = String.to_integer(id)

    {:noreply,
     socket
     |> assign(:open, Enum.reject(socket.assigns.open, fn id -> id == snippet_id end))
     |> assign(:editing, Enum.reject(socket.assigns.editing, fn id -> id == snippet_id end))
     |> assign(
       :new_snippets,
       Enum.reject(socket.assigns.new_snippets, fn id -> id == snippet_id end)
     )}
  end

  @impl true
  def handle_event("close_snippets", _, socket) do
    {:noreply,
     socket
     |> assign(:open, [])
     |> assign(:editing, [])
     |> assign(:new_snippets, [])}
  end

  def handle_event("talk_page", %{"title" => title}, socket) do
    talk_page = Snippets.find_snippet(socket.assigns.current_scope, title, "Talk")

    if is_nil(talk_page) do
      case Snippets.create_snippet(socket.assigns.current_scope, %{
             title: title,
             namespace: "Talk"
           }) do
        {:ok, talk_page} ->
          {:noreply,
           socket
           |> assign(:open, [talk_page.id | socket.assigns.open])}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Unable to create talk page. Please try again.")}
      end
    else
      if talk_page.id in socket.assigns.open do
        {:noreply, socket}
      else
        {:noreply,
         socket
         |> assign(:open, [talk_page.id | socket.assigns.open])}
      end
    end
  end

  @impl true
  def handle_event("validate_upload", _params, socket) do
    documents = socket.assigns.uploads.documents

    errors =
      documents.entries
      |> Enum.map(fn entry ->
        if Snippets.find_snippet(socket.assigns.current_scope, entry.client_name, "File") do
          {entry.ref, :already_exists}
        end
      end)
      |> Enum.filter(fn error -> not is_nil(error) and error not in documents.errors end)

    refs = Enum.map(errors, fn {ref, _} -> ref end)

    documents =
      documents
      |> Map.update!(:errors, fn e -> e ++ errors end)
      |> Map.update!(:entries, fn entries ->
        Enum.map(entries, fn entry ->
          if entry.ref in refs, do: Map.put(entry, :valid?, false), else: entry
        end)
      end)

    # :uploads is a reserved assign, so it cannot go through assign/3; update it
    # in place and mark it changed so the error renders in the next diff.
    socket = %{
      socket
      | assigns:
          socket.assigns
          |> Map.update!(:uploads, &Map.put(&1, :documents, documents))
          |> Map.update!(:__changed__, &Map.put(&1, :uploads, true))
    }

    {:noreply, socket}
  end

  @impl true
  def handle_event("save_upload", _params, socket) do
    created_snippets =
      consume_uploaded_entries(socket, :documents, fn %{path: path}, entry ->
        with {:ok, snippet} <-
               (if is_nil(
                     Snippets.find_snippet(
                       socket.assigns.current_scope,
                       entry.client_name,
                       "File"
                     )
                   ) do
                  Snippets.create_snippet(socket.assigns.current_scope, %{
                    title: entry.client_name,
                    namespace: "File"
                  })
                else
                  filename = Snippets.Snippet.create_unique_filename(entry.client_name)

                  Snippets.create_snippet(socket.assigns.current_scope, %{
                    title: filename,
                    namespace: "File"
                  })
                end),
             {:ok, content} <- File.read(path),
             {:ok, _updated_snippet} <-
               Snippets.create_new_revision(
                 socket.assigns.current_scope,
                 snippet,
                 %{},
                 content,
                 entry.client_type
               ) do
          {:ok, snippet}
        else
          _ -> {:ok, nil}
        end
      end)
      |> Enum.reject(&is_nil/1)

    {:noreply,
     socket
     |> then(fn socket ->
       if created_snippets == [] do
         put_flash(socket, :error, "Unable to upload file(s). Please try again.")
       else
         put_flash(socket, :info, "#{length(created_snippets)} file(s) uploaded successfully")
       end
     end)}
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :documents, ref)}
  end

  @impl true
  def handle_event("cancel_all_uploads", _, socket) do
    {:noreply,
     Enum.reduce(socket.assigns.uploads.documents.entries, socket, fn entry, acc ->
       cancel_upload(acc, :documents, entry.ref)
     end)}
  end

  @impl true
  def handle_event("set_mobile_view", %{"view" => view}, socket)
      when view in ["articles", "browse", "ask"] do
    {:noreply, assign(socket, :mobile_view, view)}
  end

  @impl true
  def handle_event("restore_open", %{"ids" => ids}, socket) when is_list(ids) do
    known = MapSet.new(socket.assigns.snippets, & &1.id)

    restored =
      ids
      |> Enum.map(&normalize_snippet_id/1)
      |> Enum.filter(fn id ->
        id && MapSet.member?(known, id) && id not in socket.assigns.open
      end)

    if restored == [] do
      {:noreply, socket}
    else
      # Restoring a previous session is not a new read, so views are not
      # incremented here (unlike open_snippet_card/2).
      expanded =
        socket.assigns.snippets
        |> Enum.filter(&(&1.id in restored))
        |> Enum.reduce(socket.assigns.expanded_bags, &MapSet.put(&2, &1.bag))

      {:noreply,
       socket
       |> assign(:open, socket.assigns.open ++ restored)
       |> assign(:expanded_bags, expanded)}
    end
  end

  @impl true
  def handle_event("set_sidebar_mode", %{"mode" => mode}, socket)
      when mode in ["contents", "recent", "files"] do
    {:noreply, assign(socket, :sidebar_mode, mode)}
  end

  @impl true
  def handle_event("toggle_ask", _, socket) do
    {:noreply, assign(socket, :ask_open, not socket.assigns.ask_open)}
  end

  @impl true
  def handle_event("toggle_toc_bag", %{"bag" => bag}, socket) do
    expanded =
      if MapSet.member?(socket.assigns.expanded_bags, bag) do
        MapSet.delete(socket.assigns.expanded_bags, bag)
      else
        MapSet.put(socket.assigns.expanded_bags, bag)
      end

    {:noreply, assign(socket, :expanded_bags, expanded)}
  end

  @impl true
  def handle_info({:flash, kind, msg}, socket) do
    {:noreply, put_flash(socket, kind, msg)}
  end

  @impl true
  def handle_info({:increment_view_count, snippet}, socket) do
    Snippets.increment_views(socket.assigns.current_scope, snippet)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:stop_editing, snippet}, socket) do
    {:noreply,
     socket
     |> assign(:editing, Enum.reject(socket.assigns.editing, fn id -> id == snippet.id end))
     |> assign(
       :new_snippets,
       Enum.reject(socket.assigns.new_snippets, fn id -> id == snippet.id end)
     )}
  end

  @impl true
  def handle_info({type, %Snippetwiki.Snippets.Snippet{}}, socket)
      when type in [:created, :updated, :deleted] do
    # {:noreply, stream(socket, :snippets, list_snippets(socket.assigns.current_scope), reset: true)}
    snippets = list_snippets(socket.assigns.current_scope)

    {:noreply,
     socket
     |> assign(:snippets, snippets)
     |> assign(
       :drafts,
       snippets
       |> Enum.filter(fn s -> s.has_draft end)
       |> Enum.map(fn s -> s.id end)
     )
     |> assign(
       :open,
       socket.assigns.open
       |> Enum.filter(fn id -> Enum.find_value(snippets, false, fn s -> s.id == id end) end)
     )
     |> assign(
       :editing,
       socket.assigns.editing
       |> Enum.filter(fn id -> Enum.find_value(snippets, false, fn s -> s.id == id end) end)
     )
     |> assign(
       :new_snippets,
       Enum.filter(socket.assigns.new_snippets, fn id ->
         Enum.find_value(snippets, false, fn s -> s.id == id end)
       end)
     )}
  end

  defp list_snippets(current_scope) do
    Snippets.list_snippets(current_scope)
  end

  defp open_snippet_card(socket, snippet) do
    socket =
      socket
      |> assign(:expanded_bags, MapSet.put(socket.assigns.expanded_bags, snippet.bag))
      |> assign(:mobile_view, "articles")

    socket =
      if snippet.id in socket.assigns.open do
        socket
      else
        send(self(), {:increment_view_count, snippet})

        assign(socket, :open, [snippet.id | socket.assigns.open])
      end

    push_event(socket, "scroll", %{id: "snippet-#{snippet.id}"})
  end

  # Articles or files grouped by bag in recipe order, sorted by title.
  defp toc_groups(snippets, bags_order) do
    groups_by_bag(snippets, bags_order, &is_nil(&1.namespace))
  end

  defp file_groups(snippets, bags_order) do
    groups_by_bag(snippets, bags_order, &(&1.namespace == "File"))
  end

  defp groups_by_bag(snippets, bags_order, filter_fn) do
    grouped =
      snippets
      |> Enum.filter(filter_fn)
      |> Enum.group_by(& &1.bag)

    bags_order
    |> Enum.map(fn bag ->
      {bag, Map.get(grouped, bag, []) |> Enum.sort_by(& &1.title, :asc)}
    end)
    |> Enum.reject(fn {_bag, items} -> items == [] end)
  end

  defp open_snippets(snippets, open_ids) do
    open_ids
    |> Enum.map(fn id -> Enum.find(snippets, &(&1.id == id)) end)
    |> Enum.reject(&is_nil/1)
  end

  defp recent_snippets(snippets) do
    Enum.filter(snippets, &is_nil(&1.namespace))
  end

  defp recent_by_date(snippets) do
    snippets
    |> recent_snippets()
    |> Enum.group_by(fn snippet -> DateTime.to_date(snippet.updated_at) end)
    |> Enum.sort_by(fn {date, _} -> date end, {:desc, Date})
    |> Enum.map(fn {date, day_snippets} ->
      {date, Enum.sort_by(day_snippets, & &1.updated_at, {:desc, DateTime})}
    end)
  end

  defp normalize_snippet_id(id) when is_integer(id), do: id

  defp normalize_snippet_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {n, ""} -> n
      _ -> nil
    end
  end

  defp normalize_snippet_id(_), do: nil

  defp find_available_title(base, i, snippets) do
    if Enum.find_value(snippets, fn x -> x.title == base <> " " <> Integer.to_string(i) end) do
      find_available_title(base, i + 1, snippets)
    else
      base <> " " <> Integer.to_string(i)
    end
  end

  defp wikirag_embed_url do
    Application.fetch_env!(:snippetwiki, :wikirag_url)
    |> String.trim_trailing("/")
    |> Kernel.<>("/embed.html")
  end

  defp maybe_open_welcome(socket) do
    if socket.assigns.open != [] do
      socket
    else
      case Snippets.find_snippet(socket.assigns.current_scope, "Welcome") do
        nil -> socket
        snippet -> open_snippet_card(socket, snippet)
      end
    end
  end

  defp apply_deep_link(socket, {bag, title}) do
    case open_article_in_bag(socket, bag, title) do
      {:ok, snippet} ->
        socket
        |> assign(bag: bag, pending_deep_link: nil)
        |> open_snippet_card(snippet)

      {:error, :not_found} ->
        socket
        |> assign(bag: bag, pending_deep_link: nil, missing_article: {bag, title})

      {:error, :unknown_scope} ->
        socket
        |> assign(:pending_deep_link, nil)
        |> put_flash(:error, "Unknown scope.")
    end
  end

  defp open_article_in_bag(socket, bag, title) do
    title = URI.decode(title)
    scope = socket.assigns.current_scope

    if bag in scope.user.bags do
      case Snippets.find_snippet_in_bag(scope, title, bag) do
        nil -> {:error, :not_found}
        snippet -> {:ok, snippet}
      end
    else
      {:error, :unknown_scope}
    end
  end

  defp open_initial_params(%{"title" => title, "bag" => bag, "autocreate" => _autocreate})
       when is_binary(title) and title != "" and is_binary(bag) and bag != "",
       do: %{title: title, bag: bag}

  defp open_initial_params(%{"title" => title, "bag" => bag})
       when is_binary(title) and title != "" and is_binary(bag) and bag != "",
       do: %{title: title, bag: bag}

  defp open_initial_params(%{
         "value" => %{"title" => title, "bag" => bag, "autocreate" => _autocreate}
       })
       when is_binary(title) and title != "" and is_binary(bag) and bag != "",
       do: %{title: title, bag: bag}

  defp open_initial_params(%{"value" => %{"title" => title, "bag" => bag}})
       when is_binary(title) and title != "" and is_binary(bag) and bag != "",
       do: %{title: title, bag: bag}

  defp open_initial_params(_), do: nil

  defp normalize_open_initial_title(title) do
    title
    |> decode_open_initial_title()
    |> String.replace(~r/^Notes:\s*/i, "")
    |> String.replace(~r/\s*\(#\d+\)\s*$/, "")
    |> String.replace(~r/\s*\(#\d+.*$/, "")
    |> String.trim()
  end

  defp decode_open_initial_title(title) do
    URI.decode(title)
  rescue
    ArgumentError -> title
  end
end
