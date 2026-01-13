defmodule SnippetwikiWeb.SnippetLive.Form do
  use SnippetwikiWeb, :live_view

  alias Snippetwiki.Snippets
  alias Snippetwiki.Snippets.Snippet

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage snippet records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="snippet-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Snippet</.button>
          <.button navigate={return_path(@return_to, @snippet)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    snippet = Snippets.get_snippet!(id)

    socket
    |> assign(:page_title, "Edit Snippet")
    |> assign(:snippet, snippet)
    |> assign(:form, to_form(Snippets.change_snippet(snippet)))
  end

  defp apply_action(socket, :new, _params) do
    snippet = %Snippet{}

    socket
    |> assign(:page_title, "New Snippet")
    |> assign(:snippet, snippet)
    |> assign(:form, to_form(Snippets.change_snippet(snippet)))
  end

  @impl true
  def handle_event("validate", %{"snippet" => snippet_params}, socket) do
    changeset = Snippets.change_snippet(socket.assigns.snippet, snippet_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"snippet" => snippet_params}, socket) do
    save_snippet(socket, socket.assigns.live_action, snippet_params)
  end

  defp save_snippet(socket, :edit, snippet_params) do
    case Snippets.update_snippet(socket.assigns.snippet, snippet_params) do
      {:ok, snippet} ->
        {:noreply,
         socket
         |> put_flash(:info, "Snippet updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, snippet))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_snippet(socket, :new, snippet_params) do
    case Snippets.create_snippet(snippet_params) do
      {:ok, snippet} ->
        {:noreply,
         socket
         |> put_flash(:info, "Snippet created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, snippet))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _snippet), do: ~p"/snippets"
  defp return_path("show", snippet), do: ~p"/snippets/#{snippet}"
end
