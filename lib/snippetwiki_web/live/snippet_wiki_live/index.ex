defmodule SnippetwikiWeb.SnippetWikiLive.Index do
  use SnippetwikiWeb, :live_view

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.wiki flash={@flash}>
          <div class="flex flex-col h-svh w-full min-w-0 xl:flex-1 xl:basis-1/2">
              <div class="flex justify-between gap-8 px-5 py-2">
                  <div class="flex items-center gap-3">
                      <img src={~p"/images/logo.svg"} alt="snippetwiki" class="h-8 hover:scale-110 transition-transform"/>

                      <%!-- Add button --%>
                      <div class="dropdown">
                          <div tabIndex={0} role="button" class="btn btn-square btn-ghost">
                              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                                  stroke="currentColor" class="size-6">
                                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15"/>
                              </svg>
                          </div>
                          <ul tabIndex={0} class="dropdown-content menu bg-base-100 rounded-box z-1 w-52 p-2 shadow-sm mt-2">
                              <li>
                                  <button type="button" phx-click="new_snippet">
                                      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                                          stroke="currentColor" class="size-5">
                                          <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15"/>
                                      </svg>
                                      New snippet
                                  </button>
                              </li>
                              <li>
                                <form id="upload" phx-change="validate_upload" phx-submit="save_upload">
                                  <label class="flex gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                                        stroke="currentColor" class="size-5 inline">
                                        <path strokeLinecap="round" strokeLinejoin="round"
                                              d="m18.375 12.739-7.693 7.693a4.5 4.5 0 0 1-6.364-6.364l10.94-10.94A3 3 0 1 1 19.5 7.372L8.552 18.32m.009-.01-.01.01m5.699-9.941-7.81 7.81a1.5 1.5 0 0 0 2.112 2.13"/>
                                    </svg>
                                    <span>Import files</span>
                                    <span class="hidden">
                                      <.live_file_input upload={@uploads.documents} />
                                    </span>
                                  </label>
                                </form>
                              </li>
                          </ul>
                      </div>
                  </div>

                  <.live_component
                   module={SnippetwikiWeb.SearchComponent}
                   id="search"
                   current_scope={@current_scope}/>
              </div>
              <div class="flex-1 overflow-y-scroll overscroll-none min-w-0">
                  <div class="flex flex-col gap-4 p-4">
                    <%= if length(@uploads.documents.entries) > 0 do %>
                      <section phx-drop-target={@uploads.documents.ref}>
                        <.upload uploads={@uploads} />
                      </section>
                    <% end %>

                    <%= if length(@open) > 0 do %>
                      <.live_component
                        :for={snippet <- Enum.filter(Enum.map(@open, fn snippet_id -> Enum.find(@snippets, fn snippet -> snippet_id === snippet.id end) end), fn s -> s != nil end)}
                        module={SnippetwikiWeb.SnippetComponent}
                        id={snippet.id}
                        current_scope={@current_scope}
                        snippet={Snippets.with_content(snippet)}
                        editing={Enum.member?(@editing, snippet.id)} />
                    <% end %>

                    <%= if length(@uploads.documents.entries) == 0 and length(@open) == 0 do %>
                      <div class="card p-6 select-none">
                          <div class="mx-auto py-12 mt-6 text-2xl flex flex-col items-center gap-12">
                              <img src={~p(/images/logo.svg)} alt="" class="h-[25vh] grayscale opacity-10"/>
                              <div class="text-base-content/30">No open snippets</div>
                          </div>
                      </div>
                    <% end %>
                  </div>
              </div>
          </div>

          <div class="hidden h-svh min-w-0 xl:flex xl:flex-1 xl:basis-1/2 xl:flex-col">
            <div class="flex-1 min-w-0 w-full overflow-y-scroll overscroll-none max-h-svh">

              <div class="flex items-baseline gap-2 absolute right-4 text-xs p-2 opacity-30 hover:opacity-100 transition-opacity">
                Logged in as
                <span class="badge badge-primary badge-soft badge-sm">{@current_scope.user.email}</span>
              </div>

              <%!-- <div class="filter justify-end absolute right-4">
                    <input class="btn btn-sm btn-ghost filter-reset" type="radio" name="bag" aria-label="All"/>
                    <input class="btn btn-sm" type="radio" name="bag" aria-label="HKU"/>
                    <input class="btn btn-sm" type="radio" name="bag" aria-label="Dentistry"/>
                    <input class="btn btn-sm btn-soft btn-warning" type="radio" name="bag"
                           aria-label="Journal"/>
              </div> --%>

              <div class="tabs tabs-box h-svh w-full rounded-none p-4">
                  <input
                    type="radio"
                    name="tabs"
                    class="tab"
                    aria-label="Contents"
                    checked={@active_tab == "Contents"}
                    phx-click="change_active_tab"
                    phx-value-tab="Contents"
                  />
                  <div class="tab-content p-3">
                    <div class="max-h-[calc(100lvh-10rem)] overflow-y-scroll">
                      <%= if Enum.empty?(toc_groups(@snippets, @current_scope.user.bags)) do %>
                        <div class="text-base-content/50 italic px-1">No articles yet</div>
                      <% else %>
                        <div :for={{bag, articles} <- toc_groups(@snippets, @current_scope.user.bags)} class="mb-2">
                          <details class="group" open={length(@current_scope.user.bags) == 1}>
                            <summary class="text-sm font-medium opacity-70 cursor-pointer py-1 select-none list-none flex items-center gap-2">
                              <.icon name="hero-chevron-right" class="size-3 group-open:rotate-90 transition-transform" />
                              <span class="truncate">{bag}</span>
                              <span class="text-xs opacity-50">({length(articles)})</span>
                            </summary>
                            <ul class="pl-5 mt-1 border-l border-base-300 ml-1">
                              <li :for={snippet <- articles} id={"toc-#{bag}-#{snippet.id}"} class="pb-1">
                                <a
                                  phx-click="open_snippet"
                                  phx-value-id={snippet.id}
                                  class={[
                                    "hover:text-primary transition-colors",
                                    snippet.id in @open && "font-semibold text-primary"
                                  ]}
                                >
                                  {snippet.title}
                                </a>
                                <%= if snippet.has_draft do %>
                                  <.icon name="hero-pencil" class="size-3 ms-1 opacity-50" />
                                <% end %>
                              </li>
                            </ul>
                          </details>
                        </div>
                      <% end %>
                    </div>
                  </div>

                  <input
                    type="radio"
                    name="tabs"
                    class="tab"
                    aria-label="Open"
                    checked={@active_tab == "Open"}
                    phx-click="change_active_tab"
                    phx-value-tab="Open"
                  />
                  <div class="tab-content p-3">
                    <div class="max-h-[calc(100lvh-10rem)] overflow-y-scroll">
                      <%= if Enum.empty?(@open) do %>
                        <div class="text-base-content/50 italic px-1">Nothing open</div>
                      <% else %>
                        <.live_component
                          module={SnippetwikiWeb.ListComponent}
                          id="open-snippets"
                          snippets={open_snippets(@snippets, @open)}
                          open={@open}
                        />
                      <% end %>
                    </div>
                    <%= unless Enum.empty?(@open) do %>
                      <div class="mt-4">
                        <button type="button" class="btn" phx-click="close_snippets">
                          <.icon name="hero-x-mark" />
                          Close all
                        </button>
                      </div>
                    <% end %>
                  </div>

                  <input
                    type="radio"
                    name="tabs"
                    class="tab"
                    aria-label="Recent"
                    checked={@active_tab == "Recent"}
                    phx-click="change_active_tab"
                    phx-value-tab="Recent"
                  />
                  <div class="tab-content p-3">
                    <div class="max-h-[calc(100lvh-8rem)] overflow-y-scroll">
                      <%= if Enum.empty?(recent_by_date(@snippets)) do %>
                        <div class="text-base-content/50 italic px-1">No recent articles</div>
                      <% else %>
                        <div :for={{date, day_snippets} <- recent_by_date(@snippets)} class="mb-4">
                          <div class="text-sm opacity-70 mb-1">{format_recent_date(date)}</div>
                          <ul class="pl-4">
                            <li
                              :for={snippet <- day_snippets}
                              id={"recent-#{snippet.id}"}
                              class="pb-1"
                            >
                              <a
                                phx-click="open_snippet"
                                phx-value-id={snippet.id}
                                class={[
                                  "hover:text-primary transition-colors",
                                  snippet.id in @open && "font-semibold text-primary"
                                ]}
                              >
                                {snippet.title}
                              </a>
                              <%= if snippet.has_draft do %>
                                <.icon name="hero-pencil" class="size-3 ms-1 opacity-50" />
                              <% end %>
                            </li>
                          </ul>
                        </div>
                      <% end %>
                    </div>
                  </div>

                  <input
                    type="radio"
                    name="tabs"
                    class="tab"
                    aria-label="Files"
                    checked={@active_tab == "Files"}
                    phx-click="change_active_tab"
                    phx-value-tab="Files"
                  />
                  <div class="tab-content p-3">
                    <div class="max-h-[calc(100lvh-10rem)] overflow-y-scroll">
                      <%= if Enum.empty?(file_groups(@snippets, @current_scope.user.bags)) do %>
                        <div class="text-base-content/50 italic px-1">No files yet</div>
                      <% else %>
                        <div :for={{bag, files} <- file_groups(@snippets, @current_scope.user.bags)} class="mb-2">
                          <details class="group" open={length(@current_scope.user.bags) == 1}>
                            <summary class="text-sm font-medium opacity-70 cursor-pointer py-1 select-none list-none flex items-center gap-2">
                              <.icon name="hero-chevron-right" class="size-3 group-open:rotate-90 transition-transform" />
                              <span class="truncate">{bag}</span>
                              <span class="text-xs opacity-50">({length(files)})</span>
                            </summary>
                            <ul class="pl-5 mt-1 border-l border-base-300 ml-1">
                              <li :for={snippet <- files} id={"files-#{bag}-#{snippet.id}"} class="pb-1">
                                <a
                                  phx-click="open_snippet"
                                  phx-value-id={snippet.id}
                                  class={[
                                    "hover:text-primary transition-colors",
                                    snippet.id in @open && "font-semibold text-primary"
                                  ]}
                                >
                                  {snippet.title}
                                </a>
                              </li>
                            </ul>
                          </details>
                        </div>
                      <% end %>
                    </div>
                  </div>
              </div>
            </div>
          </div>

        <div class="fixed bottom-[-4px] w-full">
            <div class="flex gap-2 px-4 overflow-y-hidden overflow-x-scroll">
                <%= for draft_id <- @drafts -- @open do %>
                  <button class="btn btn-warning btn-sm text-nowrap"
                          phx-click="edit_snippet" phx-value-id={draft_id}>
                      <svg class="size-4" fill="none" stroke="currentColor" strokeWidth="1.5" viewBox="0 0 24 24"
                            xmlns="http://www.w3.org/2000/svg">
                          <path
                              d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125"
                              strokeLinecap="round"
                              strokeLinejoin="round"/>
                      </svg>
                      <span class="max-w-24 md:max-w-48 truncate">
                        {Enum.find(@snippets, fn s -> s.id == draft_id end).title}
                      </span>
                  </button>
                <% end %>
            </div>
        </div>
    </Layouts.wiki>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Snippets.subscribe_snippets(socket.assigns.current_scope)
    end

    snippets = list_snippets(socket.assigns.current_scope)
    # |> stream(:snippets, list_snippets())}

    {:ok,
     socket
     |> assign(page_title: "Snippet Wiki",
               active_tab: "Contents",
               bag: nil,
               snippets: snippets,
               open: [],
               drafts: snippets
                       |> Enum.filter(fn s -> s.has_draft end)
                       |> Enum.map(fn s -> s.id end),
               editing: [])
     |> allow_upload(:documents, accept: ~w(.jpg .jpeg .png .webp .pdf), max_entries: 5)}
  end

  @impl true
  def handle_params(%{"bag" => bag, "title" => title}, _uri, socket) do
    scope = socket.assigns.current_scope

    if bag in scope.user.bags do
      case Snippets.find_snippet_in_bag(scope, title, bag) do
        nil ->
          {:noreply,
           socket
           |> assign(:bag, bag)
           |> put_flash(:error, "Article not found.")}

        snippet ->
          {:noreply,
           socket
           |> assign(:bag, bag)
           |> open_snippet_card(snippet)}
      end
    else
      {:noreply,
       socket
       |> put_flash(:error, "Unknown bag.")
       |> push_navigate(to: ~p"/")}
    end
  end

  def handle_params(%{"bag" => bag}, _uri, socket) do
    scope = socket.assigns.current_scope

    if bag in scope.user.bags do
      {:noreply, assign(socket, :bag, bag)}
    else
      {:noreply,
       socket
       |> put_flash(:error, "Unknown bag.")
       |> push_navigate(to: ~p"/")}
    end
  end

  def handle_params(_params, _uri, socket) do
    socket = assign(socket, :bag, nil)

    case Snippets.find_snippet(socket.assigns.current_scope, "Welcome") do
      nil -> {:noreply, socket}
      snippet -> {:noreply, open_snippet_card(socket, snippet)}
    end
  end

  @impl true
  def handle_event("new_snippet", _, socket) do
    title = find_available_title("New snippet", 1, list_snippets(socket.assigns.current_scope))

    {:ok, snippet} = Snippets.create_snippet(socket.assigns.current_scope, %{title: title})

    {:noreply,
     socket
     |> assign(:open, [snippet.id | socket.assigns.open])
     |> assign(:editing, [snippet.id | socket.assigns.editing])}
  end

  @impl true
  def handle_event("open_snippet", %{"id" => id}, socket) do
    snippet = Snippets.get_snippet!(socket.assigns.current_scope, String.to_integer(id))

    # Main articles get a bag-aware permalink; handle_params performs the open.
    # Namespaced snippets (Talk, File) are not addressable by URL, so open them
    # in place directly.
    if is_nil(snippet.namespace) do
      {:noreply, push_patch(socket, to: ~p"/bags/#{snippet.bag}/#{snippet.title}")}
    else
      {:noreply, open_snippet_card(socket, snippet)}
    end
  end

  @impl true
  def handle_event("edit_snippet", %{"id" => id}, socket) do
    snippet_id = String.to_integer(id)
    snippet = Snippets.get_snippet!(socket.assigns.current_scope, snippet_id)

    unless snippet.has_draft do
      {:ok, _} = Snippets.create_draft(socket.assigns.current_scope, snippet)
    end

    socket = assign(socket, :editing, [ snippet.id | socket.assigns.editing ])

    {:noreply,
     if snippet_id in socket.assigns.open do
       socket
     else
       assign(socket, :open, [ snippet.id | socket.assigns.open ])
     end
     |> push_event("scroll", %{id: "snippet-#{snippet_id}"})}
  end


  @impl true
  def handle_event("close_snippet", %{"id" => id}, socket) do
    snippet_id = String.to_integer(id)

    {:noreply,
    socket
    |> assign(:open, Enum.reject(socket.assigns.open, fn id -> id == snippet_id end))
    |> assign(:editing, Enum.reject(socket.assigns.editing, fn id -> id == snippet_id end))}
  end

  @impl true
  def handle_event("close_snippets", _, socket) do
    {:noreply,
    socket
    |> assign(:open, [])}
  end


  def handle_event("talk_page", %{ "title" => title }, socket) do
    talk_page = Snippets.find_snippet(socket.assigns.current_scope, title, "Talk")

    if is_nil(talk_page) do
      {:ok, talk_page} = Snippets.create_snippet(socket.assigns.current_scope, %{ title: title, namespace: "Talk" })
      {:noreply,
       socket
       |> assign(:open, [talk_page.id | socket.assigns.open])}
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
    errors = socket.assigns.uploads.documents.entries
      |> Enum.map(fn entry ->
        if not is_nil(Snippets.find_snippet(socket.assigns.current_scope, entry.client_name, "File")) do
          {entry.ref, :already_exists}
        else
          nil
        end
      end)
      |> Enum.filter(fn entry -> not is_nil(entry) and entry not in socket.assigns.uploads.documents.errors end)

    assigns = Map.update!(socket.assigns, :uploads,
      fn uploads ->
        Map.update!(uploads, :documents,
          fn documents ->
            refs = Enum.map(errors, fn {ref, _} -> ref end)

            documents
            |> Map.update!(:errors, fn e -> e ++ errors end)
            |> Map.update!(:entries,
                fn entries ->
                  Enum.map(entries, fn entry ->
                    if entry.ref in refs do
                      Map.put(entry, :valid?, false)
                    else
                      entry
                    end
                  end)
                end)
          end)
      end)

    {:noreply, Map.put(socket, :assigns, assigns)}
  end

  @impl true
  def handle_event("save_upload", _params, socket) do
    created_snippets = consume_uploaded_entries(socket, :documents, fn %{path: path}, entry ->
      snippet = if is_nil(Snippets.find_snippet(socket.assigns.current_scope, entry.client_name, "File")) do
        {:ok, snippet} = Snippets.create_snippet(socket.assigns.current_scope, %{ title: entry.client_name, namespace: "File" })
        snippet
      else
        filename = Snippets.Snippet.create_unique_filename(entry.client_name)

        {:ok, snippet} = Snippets.create_snippet(socket.assigns.current_scope, %{ title: filename, namespace: "File" })
        snippet
      end

      {:ok, content} = File.read(path)
      Snippets.create_new_revision(socket.assigns.current_scope, snippet, %{}, content, entry.client_type)

      {:ok, snippet}
    end)

    {:noreply,
     socket
     |> put_flash(:info, "#{length(created_snippets)} file(s) uploaded successfully")}
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :documents, ref)}
  end

  @impl true
  def handle_event("cancel_all_uploads", _, socket) do
    {:noreply,
      Enum.reduce(socket.assigns.uploads.documents.entries, socket,
                  fn entry, acc -> cancel_upload(acc, :documents, entry.ref) end)}
  end

  @impl true
  def handle_event("change_active_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
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
    }
  end

  @impl true
  def handle_info({type, %Snippetwiki.Snippets.Snippet{}}, socket)
      when type in [:created, :updated, :deleted] do
    # {:noreply, stream(socket, :snippets, list_snippets(socket.assigns.current_scope), reset: true)}
    snippets = list_snippets(socket.assigns.current_scope)
    {:noreply,
     socket
     |> assign(:snippets, snippets)
     |> assign(:drafts, snippets
                         |> Enum.filter(fn s -> s.has_draft end)
                         |> Enum.map(fn s -> s.id end))
     |> assign(:open, socket.assigns.open
                      |> Enum.filter(fn id -> Enum.find_value(snippets, false, fn s -> s.id == id end) end))
    }
  end

  defp list_snippets(current_scope) do
    Snippets.list_snippets(current_scope)
  end

  defp open_snippet_card(socket, snippet) do
    if snippet.id in socket.assigns.open do
      socket
    else
      send(self(), {:increment_view_count, snippet})

      socket
      |> assign(:open, [snippet.id | socket.assigns.open])
      |> push_event("scroll", %{id: "snippet-#{snippet.id}"})
    end
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

  defp format_recent_date(%Date{} = date) do
    "#{ordinal_day(date.day)} #{Calendar.strftime(date, "%B %Y")}"
  end

  defp ordinal_day(day) when day in 11..13, do: "#{day}th"

  defp ordinal_day(day) do
    case rem(day, 10) do
      1 -> "#{day}st"
      2 -> "#{day}nd"
      3 -> "#{day}rd"
      _ -> "#{day}th"
    end
  end


  defp find_available_title(base, i, snippets) do
    if Enum.find_value(snippets, fn x -> x.title == base <> " " <> Integer.to_string(i) end) do
      find_available_title(base, i + 1, snippets)
    else
      base <> " " <> Integer.to_string(i)
    end
  end
end
