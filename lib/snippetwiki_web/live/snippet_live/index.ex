defmodule SnippetwikiWeb.SnippetLive.Index do
  use SnippetwikiWeb, :live_view

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
          <div class="flex flex-col h-svh">
              <div class="flex justify-between gap-12 px-4 py-2 bg-base-300">
                  <%!-- <.header>
                    <h1 class="text-3xl p-3">Welcome to snippetwiki</h1>
                    <:actions>
                      <.button variant="primary" phx-click="new_snippet">
                        <.icon name="hero-plus" /> New Snippet
                      </.button>
                    </:actions>
                  </.header> --%>

                  <div class="flex items-center gap-3 ps-2">
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
                                  <a phx-click="new_snippet">
                                      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                                          stroke="currentColor" class="size-5">
                                          <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15"/>
                                      </svg>
                                      New snippet
                                  </a>
                              </li>
                              <li>
                                  <label aria-label="Upload file">
                                      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                                          stroke="currentColor" class="size-5">
                                          <path strokeLinecap="round" strokeLinejoin="round"
                                                d="m18.375 12.739-7.693 7.693a4.5 4.5 0 0 1-6.364-6.364l10.94-10.94A3 3 0 1 1 19.5 7.372L8.552 18.32m.009-.01-.01.01m5.699-9.941-7.81 7.81a1.5 1.5 0 0 0 2.112 2.13"/>
                                      </svg>
                                      Upload file
                                      <input class="hidden" type="file" />
                                  </label>
                              </li>
                          </ul>
                      </div>
                  </div>

                  <!-- Search button -->
                  <div class="dropdown dropdown-end w-full">
                    <label tabIndex={0} role="button" class="input w-full">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5}
                              stroke="currentColor"
                              class="h-[1em] opacity-50">
                            <path strokeLinecap="round" strokeLinejoin="round"
                                  d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"/>
                        </svg>
                        <input type="search" class="grow" placeholder="Search" />
                    </label>
                    <ul tabIndex="0" class="dropdown-content bg-base-100 rounded-box shadow-sm z-1 p-2 mt-3 w-full text-base-content/70">
                      <li class="px-3 py-2 truncate">
                          <%!-- "hover:bg-primary-content/70 hover:text-primary/70" --%>
                          <%!-- "bg-primary-content text-primary" --%>
                          <a>result.title</a>
                      </li>
                      <div class="text-base-content/50 italic px-2">No matches found</div>
                    </ul>
                </div>
              </div>
              <div class="flex-1 flex flex-col overflow-y-scroll overscroll-none xl:w-[calc(65ch+5rem)]">
                  <div class="flex flex-col gap-4 p-4">
                      <%!-- <Import files={importFiles} snippets={snippets} cancelImport={() => setImportFiles([])}/>} --%>

                      <div id="snippet.title" class="card bg-base-100">
                          <%!-- <SnippetItem snippetMetadata={snippet} editing={editing} startEditing={startEditing}
                                        updateTitle={updateTitle}
                                        discardChanges={discardChanges} saveChanges={saveChanges}
                                        deleteSnippet={deleteSnippet}
                                        closeSnippet={closeSnippet}/> --%>
                      </div>


        <div class="flex flex-col gap-8">
          <%= if length(@open) > 0 do %>
            <.live_component
              :for={snippet <- Enum.map(@open, fn snippet_id -> Enum.find(@snippets, fn snippet -> snippet_id === snippet.id end) end)}
              module={SnippetwikiWeb.SnippetLive.Show}
              id={snippet.id}
              snippet={Snippets.with_content(snippet)} />
          <% else %>
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
          </div>

          <div class="flex-1 h-svh hidden xl:block">
              <%!-- <div class="filter justify-end absolute right-4">
                  <input class="btn btn-sm btn-ghost filter-reset" type="radio" name="bag"
                          aria-label="All"/>
                  <input class="btn btn-sm" type="radio" name="bag" aria-label="HKU"/>
                  <input class="btn btn-sm" type="radio" name="bag" aria-label="Dentistry"/>
                  <input class="btn btn-sm btn-soft btn-warning" type="radio" name="bag"
                          aria-label="Journal"/>
              </div> --%>

              <div class="tabs tabs-box h-svh rounded-none p-4">
                  <input type="radio" name="tabs" class="tab" aria-label="Sidebar" />
                  <%!-- <div class="tab-content pt-3 overflow-y-scroll overscroll-none"> --%>
                  <div class="tab-content p-3">
                      <%!-- <Sidebar/> --%>
                  </div>

                  <input type="radio" name="tabs" class="tab" aria-label="Recent" checked="checked" />
                  <div class="tab-content p-3">
                      <%!-- <RecentSnippets snippets={snippets} openSnippets={openSnippets}
                                      openSnippet={openSnippet} closeSnippet={closeSnippet}/> --%>

                      <div id="snippets">
                        <div :for={snippet <- @snippets} id={"snippet-link-" <> Integer.to_string(snippet.id)}>
                          <a phx-click="open_snippet" phx-value-id={snippet.id}>{snippet.title}</a>
                        </div>
                      </div>

                      <div class="mt-4">
                        <.button phx-click="close_snippets">
                          <.icon name="hero-x-mark" /> Close all
                        </.button>
                      </div>
                  </div>

                  <input type="radio" name="tabs" class="tab" aria-label="Open" />
                  <div class="tab-content p-3">
                      <%!-- <OpenSnippets snippets={openSnippets}
                                    openSnippet={openSnippet} closeSnippet={closeSnippet}
                                    closeAllSnippets={closeAllSnippets}/> --%>
                  </div>

                  <input type="radio" name="tabs" class="tab" aria-label="Map" />
                  <div class="tab-content pt-3">
                      <%!-- {selectedTab === Tabs.Map && snippets.length > 1 && <ConceptMap snippets={snippets}/>} --%>
                  </div>
              </div>
          </div>

        <%!-- <DraftList drafts={draftSnippets} openSnippet={openSnippet}/> --%>
        <div class="fixed bottom-[-4px] w-full">
            <div class="flex gap-2 px-4 overflow-y-hidden overflow-x-scroll">
                <%= for e <- @editing -- @open do %>
                <button class="btn btn-warning btn-sm text-nowrap"
                        phx-click="open_snippet" phx-value-id={e}>
                    <svg class="size-4" fill="none" stroke="currentColor" strokeWidth="1.5" viewBox="0 0 24 24"
                          xmlns="http://www.w3.org/2000/svg">
                        <path
                            d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125"
                            strokeLinecap="round"
                            strokeLinejoin="round"/>
                    </svg>
                    {Enum.find(@snippets, fn s -> s.id == e end).title}
                </button>
                <% end %>
            </div>
        </div>
    </Layouts.app>
    """
  end
  # def render(assigns) do
  #   ~H"""
  #   <Layouts.app flash={@flash}>
  #     <.header>
  #       Listing Snippets
  #       <:actions>
  #         <.button variant="primary" navigate={~p"/snippets/new"}>
  #           <.icon name="hero-plus" /> New Snippet
  #         </.button>
  #       </:actions>
  #     </.header>

  #     <.table
  #       id="snippets"
  #       rows={@streams.snippets}
  #       row_click={fn {_id, snippet} -> JS.navigate(~p"/snippets/#{snippet}") end}
  #     >
  #       <:col :let={{_id, snippet}} label="Title">{snippet.title}</:col>
  #       <:action :let={{_id, snippet}}>
  #         <div class="sr-only">
  #           <.link navigate={~p"/snippets/#{snippet}"}>Show</.link>
  #         </div>
  #         <.link navigate={~p"/snippets/#{snippet}/edit"}>Edit</.link>
  #       </:action>
  #       <:action :let={{id, snippet}}>
  #         <.link
  #           phx-click={JS.push("delete", value: %{id: snippet.id}) |> hide("##{id}")}
  #           data-confirm="Are you sure?"
  #         >
  #           Delete
  #         </.link>
  #       </:action>
  #     </.table>
  #   </Layouts.app>
  #   """
  # end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Snippets.subscribe()
    end

    snippets = list_snippets()
    # |> stream(:snippets, list_snippets())}

    {:ok,
     socket
     |> assign(page_title: "Snippet Wiki",
               snippets: snippets,
               editing: snippets
                        |> Enum.filter(fn s -> s.has_draft end)
                        |> Enum.map(fn s -> s.id end),
               open: [])}
  end

  @impl true
  def handle_event("new_snippet", _, socket) do
    title = find_available_title("New snippet", 1, list_snippets())

    {:ok, snippet} = Snippets.create_snippet(%{title: title})

    {:noreply,
     socket
     |> assign(:open, [snippet.id | socket.assigns.open])}
  end

  @impl true
  def handle_event("open_snippet", %{"id" => id}, socket) do
    snippet_id = String.to_integer(id)
    if snippet_id in socket.assigns.open do
      {:noreply, socket}
    else
      Snippets.increment_views(snippet_id)
      {:noreply,
       socket
       |> assign(open: [ snippet_id | socket.assigns.open ])}
    end
  end

  @impl true
  def handle_event("close_snippet", %{"id" => id}, socket) do
    snippet_id = String.to_integer(id)

    {:noreply,
    socket
    |> assign(:open, Enum.reject(socket.assigns.open, fn id -> id == snippet_id end))}
  end

  @impl true
  def handle_event("close_snippets", _, socket) do
    {:noreply,
    socket
    |> assign(:open, [])}
  end


  @impl true
  def handle_info({Snippets, [:snippet | _], _}, socket) do
    snippets = list_snippets()
    {:noreply,
     socket
     |> assign(snippets: snippets,
               editing: snippets
                        |> Enum.filter(fn s -> s.has_draft end)
                        |> Enum.map(fn s -> s.id end),
               open: socket.assigns.open
                     |> Enum.filter(fn id -> Enum.find_value(snippets, false, fn s -> s.id == id end) end))
    }
  end


  defp list_snippets() do
    Snippets.list_snippets()
  end

  defp find_available_title(base, i, snippets) do
    if Enum.find_value(snippets, fn x -> x.title == base <> " " <> Integer.to_string(i) end) do
      find_available_title(base, i + 1, snippets)
    else
      base <> " " <> Integer.to_string(i)
    end
  end
end
