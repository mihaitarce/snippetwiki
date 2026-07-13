defmodule SnippetwikiWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use SnippetwikiWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar gap-2 border-b border-base-300 bg-base-100 px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href={~p"/"} class="flex w-fit items-center gap-2" title="Back to the wiki">
          <img src={~p"/images/logo.svg"} alt="snippetwiki" width="36" />
          <span class="font-serif text-lg">SnippetWiki</span>
        </a>
      </div>
      <div class="flex flex-none items-center gap-3">
        <span
          :if={@current_scope}
          class="badge badge-primary badge-soft badge-sm hidden max-w-48 truncate sm:inline-flex"
          title={@current_scope.user.email}
        >
          {@current_scope.user.email}
        </span>
      </div>
    </header>

    <main class="px-4 py-16 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  App shell for the wiki screen: full-width header on top, a flex row for
  sidebar / article stream / Ask panel, and a fixed bottom nav on mobile.

  The middle row reserves space for the mobile bottom nav via padding so
  scrollable children never hide behind it.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  slot :header
  slot :bottom
  slot :inner_block, required: true

  def wiki(assigns) do
    ~H"""
    <div class="flex h-svh min-h-0 w-full flex-col overflow-hidden bg-base-200 transition-colors">
      {render_slot(@header)}

      <main
        role="main"
        class="flex min-h-0 w-full flex-1 pb-[calc(3.5rem+env(safe-area-inset-bottom,0px))] xl:pb-0"
      >
        {render_slot(@inner_block)}
      </main>

      {render_slot(@bottom)}
    </div>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
