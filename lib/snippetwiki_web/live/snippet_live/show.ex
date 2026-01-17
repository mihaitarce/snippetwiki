defmodule SnippetwikiWeb.SnippetLive.Show do
  use SnippetwikiWeb, :live_view

  alias Snippetwiki.Snippets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
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
        <:item title="Has draft">{@snippet.has_draft}</:item>
        <:item title="Content">
          <textarea class="hidden">{@snippet.content}</textarea>
          <div id={"editor-#{@snippet.id}"} phx-hook="BlockNote" phx-update="ignore"></div>
        </:item>
        <:item title="Views">
          <div id={"views-#{@snippet.id}"} phx-hook="Number" data-number={@snippet.views} phx-update="ignore"></div>
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Snippets.subscribe_snippets(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Snippet")
     |> assign(:snippet, Snippets.get_snippet!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Snippetwiki.Snippets.Snippet{id: id} = snippet},
        %{assigns: %{snippet: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :snippet, snippet)}
  end

  def handle_info(
        {:deleted, %Snippetwiki.Snippets.Snippet{id: id}},
        %{assigns: %{snippet: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current snippet was deleted.")
     |> push_navigate(to: ~p"/")}
  end

  def handle_info({type, %Snippetwiki.Snippets.Snippet{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
