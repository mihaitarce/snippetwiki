defmodule SnippetwikiWeb.SnippetLive.Show do
  use SnippetwikiWeb, :live_view

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Snippet {@snippet.id}
        <:subtitle>This is a snippet record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/snippets"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/snippets/#{@snippet}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit snippet
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@snippet.title}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Snippet")
     |> assign(:snippet, Snippets.get_snippet!(id))}
  end
end
