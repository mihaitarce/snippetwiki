defmodule SnippetwikiWeb.SnippetLive2.Index do
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
                                    <span>Upload file</span>
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
                   module={SnippetwikiWeb.SnippetLive2.Search}
                   id="search"
                   current_scope={@current_scope}/>
              </div>
              <div class="flex-1 flex flex-col overflow-y-scroll overscroll-none max-w-screen xl:w-[calc(65ch+5rem)]">
                  <div class="flex flex-col gap-4 p-4">
                    <%= if length(@uploads.documents.entries) > 0 do %>
                      <section phx-drop-target={@uploads.documents.ref}>
                        <.upload uploads={@uploads} />
                      </section>
                    <% end %>

                    <%= if length(@open) > 0 do %>
                      <.live_component
                        :for={snippet <- Enum.filter(Enum.map(@open, fn snippet_id -> Enum.find(@snippets, fn snippet -> snippet_id === snippet.id end) end), fn s -> s != nil end)}
                        module={SnippetwikiWeb.SnippetLive2.Show}
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

          <div class="flex-1 h-svh hidden xl:block">
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

              <div class="tabs tabs-box h-svh rounded-none p-4">
                  <input type="radio" name="tabs" class="tab" aria-label="Sidebar" />
                  <%!-- <div class="tab-content pt-3 overflow-y-scroll overscroll-none"> --%>
                  <div class="tab-content p-3">
                      <%!-- <Sidebar/> --%>
                  </div>

                  <input type="radio" name="tabs" class="tab" aria-label="Recent" checked="checked" />
                  <div class="tab-content p-3">
                      <ul>
                        <li :for={snippet <- Enum.filter(@snippets, fn s -> is_nil(s.namespace) end)}
                              id={"recent-link-#{Integer.to_string(snippet.id)}"} class="pb-1">
                            <a phx-click="open_snippet" phx-value-id={snippet.id}>{snippet.title}</a>
                            <%= if snippet.has_draft do %>
                              <.icon name="hero-pencil" class="ms-2 size-4" />
                            <% end %>
                          </li>
                      </ul>

                      <div class="mt-4">
                        <button type="button" class="btn" phx-click="close_snippets">
                          <.icon name="hero-x-mark" />
                          Close all
                        </button>
                      </div>
                  </div>

                  <input type="radio" name="tabs" class="tab" aria-label="Files" />
                  <div class="tab-content p-3">
                      <div class="flex flex-col gap-1">
                        <a :for={snippet <- Enum.filter(@snippets, fn s -> s.namespace == "File" end)}
                           id={"file-link-#{Integer.to_string(snippet.id)}"}
                           phx-click="open_snippet" phx-value-id={snippet.id}>File:{snippet.title}</a>
                      </div>
                  </div>

                  <input type="radio" name="tabs" class="tab" aria-label="Map" />
                  <div class="tab-content pt-3">
                      <%!-- Concept map --%>
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
      Snippets.subscribe_snippets(socket.assigns.current_scope)
    end

    snippets = list_snippets(socket.assigns.current_scope)
    # |> stream(:snippets, list_snippets())}

    {:ok,
     socket
     |> assign(page_title: "Snippet Wiki",
               snippets: snippets,
               drafts: snippets
                        |> Enum.filter(fn s -> s.has_draft end)
                        |> Enum.map(fn s -> s.id end),
               open: [],
               editing: [],
               uploaded_files: [])
     |> allow_upload(:documents, accept: ~w(.jpg .jpeg .png .webp .pdf), max_entries: 5)}
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
    snippet_id = String.to_integer(id)
    if snippet_id in socket.assigns.open do
      {:noreply, socket}
    else
      Snippets.increment_views(socket.assigns.current_scope, snippet_id)
      {:noreply,
       socket
       |> assign(open: [ snippet_id | socket.assigns.open ])}
    end
  end

  @impl true
  def handle_event("edit_snippet", %{"id" => id}, socket) do
    snippet_id = String.to_integer(id)

    socket = assign(socket, :editing, [ snippet_id | socket.assigns.editing ])

    if snippet_id in socket.assigns.open do
      {:noreply, socket}
    else
      {:noreply, assign(socket, :open, [ snippet_id | socket.assigns.open ])}
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


  @impl Phoenix.LiveView
  def handle_event("validate_upload", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("save_upload", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :documents, fn %{path: path}, entry ->
        {:ok, snippet} = Snippets.create_snippet(socket.assigns.current_scope, %{ title: entry.client_name, namespace: "File" })
        {:ok, content} = File.read(path)
        Snippets.create_new_revision(socket.assigns.current_scope, snippet, %{}, content, entry.client_type)

        {:ok, path}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :documents, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel_all_uploads", _, socket) do
    {:noreply,
      Enum.reduce(socket.assigns.uploads.documents.entries, socket,
                  fn entry, acc -> cancel_upload(acc, :documents, entry.ref) end)}
  end


  @impl true
  def handle_info({:start_editing, snippet}, socket) do
    {:noreply,
     socket
     |> assign(:editing, [ snippet.id | socket.assigns.editing ])}
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


  defp find_available_title(base, i, snippets) do
    if Enum.find_value(snippets, fn x -> x.title == base <> " " <> Integer.to_string(i) end) do
      find_available_title(base, i + 1, snippets)
    else
      base <> " " <> Integer.to_string(i)
    end
  end
end
