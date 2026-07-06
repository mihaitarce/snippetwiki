defmodule SnippetwikiWeb.SnippetWikiLive.Index do
  use SnippetwikiWeb, :live_view

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.wiki flash={@flash}>
          <div id="wiki-hash-open" phx-hook="WikiHashOpen" data-default-bag={@current_scope.user.bag}></div>
          <div class={[
            "flex flex-col h-svh w-full min-w-0 min-h-0",
            "xl:flex-1 xl:basis-1/2",
            @mobile_view != "articles" && "hidden xl:flex"
          ]}>
              <div class="flex justify-between gap-3 sm:gap-8 px-3 sm:px-5 py-2 shrink-0">
                  <div class="flex items-center gap-3">
                      <a href="/">
                        <img src={~p"/images/logo.svg"} alt="snippetwiki" class="h-8 hover:scale-110 transition-transform"/>
                      </a>

                      <%!-- Add button --%>
                      <div id="add-dropdown" class="dropdown">
                          <div
                            id="add-dropdown-trigger"
                            tabIndex={0}
                            role="button"
                            class="btn btn-square btn-ghost"
                            phx-click={JS.remove_class("dropdown-close", to: "#add-dropdown")}
                          >
                              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                                  stroke="currentColor" class="size-6">
                                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15"/>
                              </svg>
                          </div>
                          <ul id="add-dropdown-menu" tabIndex={0} class="dropdown-content menu bg-base-100 rounded-box z-1 w-52 p-2 shadow-sm mt-2">
                              <li>
                                  <button
                                    type="button"
                                    phx-click={
                                      JS.push("new_snippet")
                                      |> JS.add_class("dropdown-close", to: "#add-dropdown")
                                      |> JS.dispatch("blur", to: "#add-dropdown-trigger")
                                      |> JS.dispatch("blur", to: "#add-dropdown-menu")
                                    }
                                  >
                                      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                                          stroke="currentColor" class="size-5">
                                          <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15"/>
                                      </svg>
                                      New snippet
                                  </button>
                              </li>
                              <li>
                                <form id="upload" phx-change="validate_upload" phx-submit="save_upload">
                                  <label
                                    class="flex gap-2"
                                    phx-click={
                                      JS.add_class("dropdown-close", to: "#add-dropdown")
                                      |> JS.dispatch("blur", to: "#add-dropdown-trigger")
                                      |> JS.dispatch("blur", to: "#add-dropdown-menu")
                                    }
                                  >
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
              </div>
              <div id="articles-scroll" class={[
                "flex-1 overflow-y-auto overscroll-none min-w-0 xl:pb-0",
                length(@drafts -- @open) > 0 && "pb-[calc(7.5rem+env(safe-area-inset-bottom,0px))]",
                length(@drafts -- @open) == 0 && "pb-[calc(4.5rem+env(safe-area-inset-bottom,0px))]"
              ]}>
                  <div class="flex flex-col gap-3 sm:gap-4 p-3 sm:p-4">
                    <%= if length(@uploads.documents.entries) > 0 do %>
                      <section phx-drop-target={@uploads.documents.ref}>
                        <.upload uploads={@uploads} />
                      </section>
                    <% end %>

                    <%= if length(@open) > 0 do %>
                      <div
                        :for={snippet <- Enum.filter(Enum.map(@open, fn snippet_id -> Enum.find(@snippets, fn snippet -> snippet_id === snippet.id end) end), fn s -> s != nil end)}
                        id={"snippet-#{snippet.id}"}
                      >
                        <.live_component
                          module={SnippetwikiWeb.SnippetComponent}
                          id={snippet.id}
                          current_scope={@current_scope}
                          snippet={Snippets.with_content(snippet)}
                          editing={Enum.member?(@editing, snippet.id)}
                          new_snippet={snippet.id in @new_snippets} />
                      </div>
                    <% end %>

                    <%= if length(@uploads.documents.entries) == 0 and length(@open) == 0 and is_nil(@missing_article) do %>
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

          <div class={[
            "h-svh min-h-0 min-w-0 w-full bg-base-200 flex flex-col",
            "pb-[calc(3.5rem+env(safe-area-inset-bottom,0px))] xl:pb-0",
            @mobile_view != "browse" && "hidden",
            "xl:flex xl:flex-1 xl:basis-1/2"
          ]}>
            <div class="relative flex min-h-0 w-full flex-1 flex-col bg-base-200 px-2 sm:pl-4 sm:pr-0">

              <div class="absolute right-2 sm:right-4 top-0 z-10 flex max-w-[55%] items-baseline gap-1.5 p-2 text-xs opacity-30 transition-opacity hover:opacity-100 sm:max-w-none">
                <span class="hidden sm:inline">Logged in as</span>
                <span class="badge badge-primary badge-soft badge-sm truncate max-w-full">{@current_scope.user.email}</span>
              </div>

              <%!-- <div class="filter justify-end absolute right-4">
                    <input class="btn btn-sm btn-ghost filter-reset" type="radio" name="bag" aria-label="All"/>
                    <input class="btn btn-sm" type="radio" name="bag" aria-label="HKU"/>
                    <input class="btn btn-sm" type="radio" name="bag" aria-label="Dentistry"/>
                    <input class="btn btn-sm btn-soft btn-warning" type="radio" name="bag"
                           aria-label="Journal"/>
              </div> --%>

              <div class="wiki-sidebar-tabs tabs tabs-box tabs-top h-full min-h-0 w-full min-w-0 flex-1 rounded-none p-1 shadow-none">
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
                          <button
                            type="button"
                            phx-click="toggle_toc_bag"
                            phx-value-bag={bag}
                            class="text-sm font-medium opacity-70 cursor-pointer py-1 select-none flex items-center gap-2 w-full text-left"
                          >
                            <.icon
                              name="hero-chevron-right"
                              class={["size-3 transition-transform", bag in @expanded_bags && "rotate-90"]}
                            />
                            <span class="truncate">{bag}</span>
                            <span class="text-xs opacity-50">({length(articles)})</span>
                          </button>
                          <%= if bag in @expanded_bags do %>
                            <ul class="pl-5 mt-1 border-l border-base-300 ml-1">
                              <li :for={snippet <- articles} id={"toc-#{bag}-#{snippet.id}"} class="pb-1">
                                <button
                                  type="button"
                                  phx-click="open_snippet"
                                  phx-value-id={snippet.id}
                                  class={[
                                    "hover:text-primary transition-colors text-left",
                                    snippet.id in @open && "font-semibold text-primary"
                                  ]}
                                >
                                  {snippet.title}
                                </button>
                                <%= if snippet.has_draft do %>
                                  <.icon name="hero-pencil" class="size-3 ms-1 opacity-50" />
                                <% end %>
                              </li>
                            </ul>
                          <% end %>
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
                              <button
                                type="button"
                                phx-click="open_snippet"
                                phx-value-id={snippet.id}
                                class={[
                                  "hover:text-primary transition-colors text-left",
                                  snippet.id in @open && "font-semibold text-primary"
                                ]}
                              >
                                {snippet.title}
                              </button>
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
                          <button
                            type="button"
                            phx-click="toggle_toc_bag"
                            phx-value-bag={bag}
                            class="text-sm font-medium opacity-70 cursor-pointer py-1 select-none flex items-center gap-2 w-full text-left"
                          >
                            <.icon
                              name="hero-chevron-right"
                              class={["size-3 transition-transform", bag in @expanded_bags && "rotate-90"]}
                            />
                            <span class="truncate">{bag}</span>
                            <span class="text-xs opacity-50">({length(files)})</span>
                          </button>
                          <%= if bag in @expanded_bags do %>
                            <ul class="pl-5 mt-1 border-l border-base-300 ml-1">
                              <li :for={snippet <- files} id={"files-#{bag}-#{snippet.id}"} class="pb-1">
                                <button
                                  type="button"
                                  phx-click="open_snippet"
                                  phx-value-id={snippet.id}
                                  class={[
                                    "hover:text-primary transition-colors text-left",
                                    snippet.id in @open && "font-semibold text-primary"
                                  ]}
                                >
                                  {snippet.title}
                                </button>
                              </li>
                            </ul>
                          <% end %>
                        </div>
                      <% end %>
                    </div>
                  </div>

                  <input
                    type="radio"
                    name="tabs"
                    class="tab"
                    aria-label="Ask/Search"
                    checked={@active_tab == "Ask/Search"}
                    phx-click="change_active_tab"
                    phx-value-tab="Ask/Search"
                  />
                  <div
                    id="wikirag-embed-wrapper"
                    phx-hook="WikiRagEmbed"
                    class="tab-content w-full min-w-0 pt-2 sm:pt-[10px] pr-1 sm:pr-[10px]"
                  >
                    <iframe
                      id="wikirag-embed"
                      src={@wikirag_embed_url}
                      class="block w-full min-w-0 xl:h-[calc(100lvh-6rem)] border border-base-300 rounded-box"
                      title="Ask/Search"
                    />
                  </div>
              </div>
            </div>
          </div>

        <nav
          id="mobile-nav"
          class="fixed inset-x-0 bottom-0 z-40 border-t border-base-300 bg-base-100/95 backdrop-blur-sm xl:hidden pb-[env(safe-area-inset-bottom,0px)]"
          aria-label="Mobile navigation"
        >
          <div class="grid h-14 grid-cols-2">
            <button
              type="button"
              phx-click="set_mobile_view"
              phx-value-view="articles"
              class={[
                "flex flex-col items-center justify-center gap-0.5 text-xs font-medium transition-colors",
                @mobile_view == "articles" && "bg-primary/10 text-primary"
              ]}
            >
              <.icon name="hero-document-text" class="size-5" />
              <span>Read</span>
            </button>
            <button
              type="button"
              phx-click="set_mobile_view"
              phx-value-view="browse"
              class={[
                "flex flex-col items-center justify-center gap-0.5 text-xs font-medium transition-colors",
                @mobile_view == "browse" && "bg-primary/10 text-primary"
              ]}
            >
              <.icon name="hero-squares-2x2" class="size-5" />
              <span>Browse</span>
            </button>
          </div>
        </nav>

        <div class="fixed bottom-14 xl:bottom-[-4px] inset-x-0 z-30 pb-[env(safe-area-inset-bottom,0px)] xl:pb-0">
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
                        {snippet_title(@snippets, draft_id)}
                      </span>
                  </button>
                <% end %>
            </div>
        </div>

      <%= if @missing_article do %>
        <% {_bag, title} = @missing_article %>
        <div id="missing-article-modal" class="modal modal-open">
          <div class="modal-box">
            <h3 class="font-bold text-lg">Article not found</h3>
            <p class="py-4">
              "{title}" was not found. Create new article?
            </p>
            <div class="modal-action">
              <button type="button" class="btn btn-ghost" phx-click="dismiss_missing_snippet">
                No
              </button>
              <button type="button" class="btn btn-primary" phx-click="create_missing_snippet">
                Yes
              </button>
            </div>
          </div>
          <button type="button" class="modal-backdrop" phx-click="dismiss_missing_snippet" aria-label="Close" />
        </div>
      <% end %>
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
       active_tab: "Contents",
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

    socket =
      unless snippet.has_draft do
        case Snippets.create_draft(socket.assigns.current_scope, snippet) do
          {:ok, _} -> socket
          {:error, _} -> put_flash(socket, :error, "Unable to start editing right now.")
        end
      else
        socket
      end

    socket =
      socket
      |> assign(:mobile_view, "articles")
      |> assign(:editing, [ snippet.id | socket.assigns.editing ])

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
    |> assign(:editing, Enum.reject(socket.assigns.editing, fn id -> id == snippet_id end))
    |> assign(:new_snippets, Enum.reject(socket.assigns.new_snippets, fn id -> id == snippet_id end))}
  end

  @impl true
  def handle_event("close_snippets", _, socket) do
    {:noreply,
    socket
    |> assign(:open, [])
    |> assign(:editing, [])
    |> assign(:new_snippets, [])}
  end


  def handle_event("talk_page", %{ "title" => title }, socket) do
    talk_page = Snippets.find_snippet(socket.assigns.current_scope, title, "Talk")

    if is_nil(talk_page) do
      case Snippets.create_snippet(socket.assigns.current_scope, %{ title: title, namespace: "Talk" }) do
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
      with {:ok, snippet} <-
             (if is_nil(Snippets.find_snippet(socket.assigns.current_scope, entry.client_name, "File")) do
               Snippets.create_snippet(socket.assigns.current_scope, %{ title: entry.client_name, namespace: "File" })
             else
               filename = Snippets.Snippet.create_unique_filename(entry.client_name)
               Snippets.create_snippet(socket.assigns.current_scope, %{ title: filename, namespace: "File" })
             end),
           {:ok, content} <- File.read(path),
           {:ok, _updated_snippet} <- Snippets.create_new_revision(socket.assigns.current_scope, snippet, %{}, content, entry.client_type) do
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
      Enum.reduce(socket.assigns.uploads.documents.entries, socket,
                  fn entry, acc -> cancel_upload(acc, :documents, entry.ref) end)}
  end

  @impl true
  def handle_event("set_mobile_view", %{"view" => view}, socket)
      when view in ["articles", "browse"] do
    {:noreply, assign(socket, :mobile_view, view)}
  end

  @impl true
  def handle_event("change_active_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
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
  def handle_info({:increment_view_count, snippet}, socket) do
    Snippets.increment_views(socket.assigns.current_scope, snippet)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:stop_editing, snippet}, socket) do
    {:noreply,
     socket
     |> assign(:editing, Enum.reject(socket.assigns.editing, fn id -> id == snippet.id end))
     |> assign(:new_snippets, Enum.reject(socket.assigns.new_snippets, fn id -> id == snippet.id end))}
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
     |> assign(:editing, socket.assigns.editing
                      |> Enum.filter(fn id -> Enum.find_value(snippets, false, fn s -> s.id == id end) end))
     |> assign(:new_snippets, Enum.filter(socket.assigns.new_snippets, fn id ->
          Enum.find_value(snippets, false, fn s -> s.id == id end)
        end))}
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

  defp open_initial_params(%{"value" => %{"title" => title, "bag" => bag, "autocreate" => _autocreate}})
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

  defp snippet_title(snippets, id) do
    case Enum.find(snippets, fn s -> s.id == id end) do
      nil -> "Draft"
      snippet -> snippet.title
    end
  end
end
