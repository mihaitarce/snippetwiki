defmodule SnippetwikiWeb.WikiComponents do
  @moduledoc """
  Function components for the main wiki screen (app shell, sidebar,
  article stream, Ask panel, mobile navigation).

  These are pure function components: all events land on the parent
  LiveView (`SnippetwikiWeb.SnippetWikiLive.Index`).
  """
  use SnippetwikiWeb, :html

  @doc """
  Full-width top header bar: logo, add menu, Ask toggle and user menu.
  """
  attr :current_scope, :map, required: true
  attr :uploads, :any, required: true
  attr :ask_open, :boolean, required: true

  def wiki_header(assigns) do
    ~H"""
    <header
      id="wiki-header"
      class="navbar min-h-14 h-14 w-full shrink-0 gap-1 sm:gap-2 border-b border-base-300 bg-base-100 px-2 sm:px-4 z-30"
    >
      <a href={~p"/"} class="shrink-0 px-1">
        <img
          src={~p"/images/logo.svg"}
          alt="snippetwiki"
          class="h-8 hover:scale-110 transition-transform"
        />
      </a>

      <.add_menu uploads={@uploads} />

      <div class="flex-1" />

      <button
        type="button"
        id="ask-toggle"
        phx-click="toggle_ask"
        class={[
          "btn btn-sm gap-1.5 hidden xl:inline-flex transition-colors",
          @ask_open && "btn-primary",
          !@ask_open && "btn-primary btn-soft"
        ]}
        title="Ask the wiki"
      >
        <.icon name="hero-sparkles" class="size-4" /> Ask
      </button>

      <.user_menu current_scope={@current_scope} />
    </header>
    """
  end

  # "+" dropdown: new snippet and file import. Keeps the single #upload form
  # holding the only <.live_file_input> on the page.
  attr :uploads, :any, required: true

  defp add_menu(assigns) do
    ~H"""
    <div id="add-dropdown" class="dropdown">
      <div
        id="add-dropdown-trigger"
        tabindex="0"
        role="button"
        class="btn btn-square btn-ghost"
        title="Add"
        phx-click={JS.remove_class("dropdown-close", to: "#add-dropdown")}
      >
        <.icon name="hero-plus" class="size-6" />
      </div>
      <ul
        id="add-dropdown-menu"
        tabindex="0"
        class="dropdown-content menu bg-base-100 rounded-box z-40 w-52 p-2 shadow-lg border border-base-300/60 mt-2"
      >
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
            <.icon name="hero-plus" class="size-5" /> New snippet
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
              <.icon name="hero-paper-clip" class="size-5" />
              <span>Import files</span>
              <span class="hidden">
                <.live_file_input upload={@uploads.documents} />
              </span>
            </label>
          </form>
        </li>
      </ul>
    </div>
    """
  end

  attr :current_scope, :map, required: true

  defp user_menu(assigns) do
    ~H"""
    <div
      id="user-menu"
      class="flex h-8 max-w-28 shrink-0 items-center rounded-full border border-base-300 px-3 sm:max-w-56"
      title={@current_scope.user.email}
    >
      <span class="truncate text-sm font-medium">
        {@current_scope.user.email}
      </span>
    </div>
    """
  end

  @doc """
  Browse sidebar: Contents/Recent/Files mode switcher plus persistent
  Open and Drafts sections. Doubles as the full-width "Browse" view on mobile.
  """
  attr :sidebar_mode, :string, required: true
  attr :mobile_view, :string, required: true
  attr :toc_groups, :list, required: true
  attr :file_groups, :list, required: true
  attr :recent_groups, :list, required: true
  attr :expanded_bags, :any, required: true
  attr :open, :list, required: true
  attr :open_snippets, :list, required: true
  attr :draft_snippets, :list, required: true

  def wiki_sidebar(assigns) do
    ~H"""
    <aside
      id="wiki-sidebar"
      class={[
        "w-full min-h-0 flex-col bg-base-100 border-base-300",
        "xl:flex xl:w-[var(--sidebar-w,18rem)] xl:shrink-0 xl:border-r",
        @mobile_view == "browse" && "flex",
        @mobile_view != "browse" && "hidden"
      ]}
    >
      <div class="join w-full px-3 pt-3 pb-2 shrink-0">
        <button
          :for={{mode, label} <- [{"contents", "Contents"}, {"recent", "Recent"}, {"files", "Files"}]}
          type="button"
          id={"sidebar-mode-#{mode}"}
          phx-click="set_sidebar_mode"
          phx-value-mode={mode}
          class={[
            "join-item btn btn-sm flex-1 font-medium",
            @sidebar_mode == mode && "btn-active",
            @sidebar_mode != mode && "btn-ghost text-base-content/60 hover:text-base-content"
          ]}
        >
          {label}
        </button>
      </div>

      <div class="flex-1 min-h-0 overflow-y-auto px-3 pb-4">
        <%= case @sidebar_mode do %>
          <% "contents" -> %>
            <%= if Enum.empty?(@toc_groups) do %>
              <.wiki_empty_state text="No articles yet" />
            <% else %>
              <.bag_group_list
                id_prefix="toc"
                groups={@toc_groups}
                expanded_bags={@expanded_bags}
                open={@open}
              />
            <% end %>
          <% "recent" -> %>
            <%= if Enum.empty?(@recent_groups) do %>
              <.wiki_empty_state text="No recent articles" />
            <% else %>
              <.recent_list groups={@recent_groups} open={@open} />
            <% end %>
          <% "files" -> %>
            <%= if Enum.empty?(@file_groups) do %>
              <.wiki_empty_state text="No files yet" />
            <% else %>
              <.bag_group_list
                id_prefix="files"
                groups={@file_groups}
                expanded_bags={@expanded_bags}
                open={@open}
                show_draft={false}
              />
            <% end %>
        <% end %>
      </div>

      <div :if={@open != []} id="open-section" class="shrink-0 border-t border-base-300 px-3 py-2">
        <div class="flex items-center justify-between">
          <span class="text-xs font-semibold uppercase tracking-wide text-base-content/50">
            Open ({length(@open_snippets)})
          </span>
          <button type="button" class="btn btn-ghost btn-xs gap-1" phx-click="close_snippets">
            <.icon name="hero-x-mark" class="size-3.5" /> Close all
          </button>
        </div>
        <ul class="mt-1 max-h-40 overflow-y-auto">
          <.snippet_link
            :for={snippet <- @open_snippets}
            snippet={snippet}
            dom_id={"open-#{snippet.id}"}
            open={@open}
            closable
          />
        </ul>
      </div>

      <div
        :if={@draft_snippets != []}
        id="drafts-section"
        class="shrink-0 border-t border-base-300 bg-warning/5 px-3 py-2"
      >
        <span class="text-xs font-semibold uppercase tracking-wide text-warning">
          Drafts ({length(@draft_snippets)})
        </span>
        <ul class="mt-1 max-h-32 overflow-y-auto">
          <li :for={snippet <- @draft_snippets} id={"draft-#{snippet.id}"} class="pb-1">
            <button
              type="button"
              phx-click="edit_snippet"
              phx-value-id={snippet.id}
              class="flex w-full items-center gap-2 text-left hover:text-warning transition-colors"
              title="Resume editing"
            >
              <.icon name="hero-pencil" class="size-3.5 shrink-0 text-warning" />
              <span class="truncate">{snippet.title}</span>
            </button>
          </li>
        </ul>
      </div>
    </aside>
    """
  end

  @doc """
  Articles or files grouped by bag with collapsible headers.
  The single shared markup for the Contents and Files sidebar modes.
  """
  attr :id_prefix, :string, required: true
  attr :groups, :list, required: true
  attr :expanded_bags, :any, required: true
  attr :open, :list, required: true
  attr :show_draft, :boolean, default: true

  def bag_group_list(assigns) do
    ~H"""
    <div :for={{bag, snippets} <- @groups} class="mb-2">
      <button
        type="button"
        phx-click="toggle_toc_bag"
        phx-value-bag={bag}
        class="flex w-full items-center gap-2 rounded-field px-1 py-1 text-left text-sm font-medium text-base-content/70 hover:bg-base-200 hover:text-base-content transition-colors select-none"
      >
        <.icon
          name="hero-chevron-right"
          class={["size-3 transition-transform", bag in @expanded_bags && "rotate-90"]}
        />
        <span class="truncate">{bag}</span>
        <span class="text-xs text-base-content/40">({length(snippets)})</span>
      </button>
      <ul :if={bag in @expanded_bags} class="pl-5 mt-1 border-l border-base-300 ml-1">
        <.snippet_link
          :for={snippet <- snippets}
          snippet={snippet}
          dom_id={"#{@id_prefix}-#{bag}-#{snippet.id}"}
          open={@open}
          show_draft={@show_draft}
        />
      </ul>
    </div>
    """
  end

  @doc """
  A single snippet row: title button with active/draft indicators
  and an optional close control.
  """
  attr :snippet, :map, required: true
  attr :dom_id, :string, required: true
  attr :open, :list, required: true
  attr :closable, :boolean, default: false
  attr :show_draft, :boolean, default: true

  def snippet_link(assigns) do
    ~H"""
    <li id={@dom_id} class="pb-1">
      <div class="flex items-center gap-1 min-w-0">
        <button
          type="button"
          phx-click="open_snippet"
          phx-value-id={@snippet.id}
          class={[
            "truncate text-left transition-colors hover:text-primary",
            @snippet.id in @open && "font-semibold text-primary"
          ]}
        >
          {@snippet.title}
        </button>
        <.icon
          :if={@show_draft and @snippet.has_draft}
          name="hero-pencil"
          class="size-3 shrink-0 opacity-50"
        />
        <button
          :if={@closable}
          type="button"
          phx-click="close_snippet"
          phx-value-id={@snippet.id}
          class="ml-auto shrink-0 cursor-pointer text-base-content/40 hover:text-base-content transition-colors"
          aria-label={"Close #{@snippet.title}"}
        >
          <.icon name="hero-x-mark" class="size-4" />
        </button>
      </div>
    </li>
    """
  end

  @doc """
  Recently updated articles grouped by day.
  """
  attr :groups, :list, required: true
  attr :open, :list, required: true

  def recent_list(assigns) do
    ~H"""
    <div :for={{date, snippets} <- @groups} class="mb-4">
      <div class="text-sm text-base-content/60 mb-1">{format_recent_date(date)}</div>
      <ul class="pl-4">
        <.snippet_link
          :for={snippet <- snippets}
          snippet={snippet}
          dom_id={"recent-#{snippet.id}"}
          open={@open}
        />
      </ul>
    </div>
    """
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

  @doc """
  Collapsible Ask/Search panel hosting the WikiRag iframe.

  The panel is ALWAYS rendered; visibility is toggled with classes only so
  the iframe never remounts (which would reset the chat). Do not wrap it in
  `:if` or move it in the DOM.
  """
  attr :ask_open, :boolean, required: true
  attr :mobile_view, :string, required: true
  attr :wikirag_embed_url, :string, required: true

  def ask_panel(assigns) do
    ~H"""
    <aside
      id="ask-panel"
      class={[
        "z-20 min-h-0 flex-col border-base-300 bg-base-100",
        "fixed inset-x-0 top-14 bottom-[calc(3.5rem+env(safe-area-inset-bottom,0px))]",
        "xl:static xl:inset-auto xl:w-[var(--ask-w,28rem)] xl:shrink-0 xl:border-l",
        @mobile_view == "ask" && "flex",
        @mobile_view != "ask" && "hidden",
        @ask_open && "xl:flex",
        !@ask_open && "xl:hidden"
      ]}
    >
      <div id="wikirag-embed-wrapper" phx-hook="WikiRagEmbed" class="min-h-0 flex-1 p-2 xl:p-3">
        <iframe
          id="wikirag-embed"
          src={@wikirag_embed_url}
          class="block h-full w-full rounded-box border border-base-300"
          title="Ask"
        />
      </div>
    </aside>
    """
  end

  @doc """
  Fixed bottom navigation on mobile: Read / Browse / Ask.
  """
  attr :mobile_view, :string, required: true
  attr :draft_count, :integer, default: 0

  def mobile_nav(assigns) do
    ~H"""
    <nav
      id="mobile-nav"
      class="fixed inset-x-0 bottom-0 z-40 border-t border-base-300 bg-base-100/95 backdrop-blur-sm xl:hidden pb-[env(safe-area-inset-bottom,0px)]"
      aria-label="Mobile navigation"
    >
      <div class="grid h-14 grid-cols-3">
        <.mobile_nav_item
          view="articles"
          label="Read"
          icon="hero-document-text"
          active={@mobile_view == "articles"}
        />
        <.mobile_nav_item
          view="browse"
          label="Browse"
          icon="hero-squares-2x2"
          active={@mobile_view == "browse"}
          badge={@draft_count}
        />
        <.mobile_nav_item
          view="ask"
          label="Ask"
          icon="hero-sparkles"
          active={@mobile_view == "ask"}
        />
      </div>
    </nav>
    """
  end

  attr :view, :string, required: true
  attr :label, :string, required: true
  attr :icon, :string, required: true
  attr :active, :boolean, required: true
  attr :badge, :integer, default: 0

  defp mobile_nav_item(assigns) do
    ~H"""
    <button
      type="button"
      phx-click="set_mobile_view"
      phx-value-view={@view}
      class={[
        "relative flex flex-col items-center justify-center gap-0.5 text-xs font-medium transition-colors",
        @active && "bg-primary/10 text-primary",
        !@active && "text-base-content/60 hover:text-base-content"
      ]}
    >
      <span class="relative">
        <.icon name={@icon} class="size-5" />
        <span
          :if={@badge > 0}
          class="badge badge-warning badge-xs absolute -right-2.5 -top-1.5 px-1 font-semibold"
        >
          {@badge}
        </span>
      </span>
      <span>{@label}</span>
    </button>
    """
  end

  @doc """
  Modal shown when a deep link points at an article that does not exist.
  """
  attr :missing_article, :any, required: true

  def missing_article_modal(assigns) do
    ~H"""
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
        <button
          type="button"
          class="modal-backdrop"
          phx-click="dismiss_missing_snippet"
          aria-label="Close"
        />
      </div>
    <% end %>
    """
  end

  @doc """
  Quiet empty-state text for sidebar lists.
  """
  attr :text, :string, required: true

  def wiki_empty_state(assigns) do
    ~H"""
    <div class="px-1 py-2 text-base-content/50 italic">{@text}</div>
    """
  end
end
