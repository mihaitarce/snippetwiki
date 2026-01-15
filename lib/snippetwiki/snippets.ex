defmodule Snippetwiki.Snippets do
  @moduledoc """
  The Snippets context.
  """

  import Ecto.Query, warn: false
  alias Snippetwiki.Repo

  alias Snippetwiki.Snippets.Snippet
  alias Snippetwiki.Snippets.Revision
  alias Snippetwiki.Snippets.Like
  alias Snippetwiki.Snippets.User

  @doc """
  Returns the list of snippets.

  ## Examples

      iex> list_snippets()
      [%Snippet{}, ...]

  """
  def list_snippets do
    likes_count = from(l in Like, where: l.snippet_id == parent_as(:snippet).id, select: count())

    query = from s in Snippet, as: :snippet,
      select_merge: %{like_count: subquery(likes_count)},
      order_by: [desc: :updated_at, desc: :id]

    Repo.all(query)
  end

  @doc """
  Gets a single snippet.

  Raises `Ecto.NoResultsError` if the Snippet does not exist.

  ## Examples

      iex> get_snippet!(123)
      %Snippet{}

      iex> get_snippet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_snippet!(id), do: Repo.get!(Snippet, id)

  def find_snippet!(name) do
    query = from s in Snippet, as: :snippet,
      where: s.title == ^name,
      left_join: r in assoc(s, :revisions),
      select_merge: %{content: r.content, content_type: r.content_type},
      order_by: [desc: r.version],
      limit: 1

    Repo.one!(query)
  end

  def with_content(snippet) do
    likes_count = from(l in Like, where: l.snippet_id == parent_as(:snippet).id, select: count())

    query = from s in Snippet, as: :snippet,
      where: s.id == ^snippet.id,
      left_join: r in assoc(s, :revisions),
      select_merge: %{like_count: subquery(likes_count)},
      select_merge: %{content: r.content, content_type: r.content_type},
      order_by: [desc: r.version],
      limit: 1

    Repo.one(query)
  end

  @doc """
  Creates a snippet.

  ## Examples

      iex> create_snippet(%{field: value})
      {:ok, %Snippet{}}

      iex> create_snippet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_snippet(attrs) do
    %Snippet{}
    |> Snippet.changeset(attrs)
    |> Repo.insert()
    |> broadcast_change([:snippet, :created])
  end

  @doc """
  Updates a snippet.

  ## Examples

      iex> update_snippet(snippet, %{field: new_value})
      {:ok, %Snippet{}}

      iex> update_snippet(snippet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_snippet(%Snippet{} = snippet, attrs) do
    snippet
    |> Snippet.changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:snippet, :updated])
  end

  @doc """
  Deletes a snippet.

  ## Examples

      iex> delete_snippet(snippet)
      {:ok, %Snippet{}}

      iex> delete_snippet(snippet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_snippet(%Snippet{} = snippet) do
    snippet
    |> Repo.delete()
    |> broadcast_change([:snippet, :deleted])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking snippet changes.

  ## Examples

      iex> change_snippet(snippet)
      %Ecto.Changeset{data: %Snippet{}}

  """
  def change_snippet(%Snippet{} = snippet, attrs \\ %{}) do
    Snippet.changeset(snippet, attrs)
  end

  def create_draft(%Snippet{} = snippet) do
    Snippet
    |> where(id: ^snippet.id)
    |> Repo.update_all(set: [has_draft: true])

    broadcast_change({:ok, %{id: snippet.id}}, [:snippet, :updated])
  end

  def discard_draft(%Snippet{} = snippet) do
    Snippet
    |> where(id: ^snippet.id)
    |> Repo.update_all(set: [has_draft: false])

    broadcast_change({:ok, %{id: snippet.id}}, [:snippet, :updated])
  end

  def create_new_revision(snippet, attrs, content, content_type \\ "text/html") do
    # Create new revision
    {:ok, _} = Repo.insert(%Revision{snippet: snippet, content: content, content_type: content_type})

    # Update snippet
    update_snippet(snippet, attrs)
  end

  def increment_views(id) do
      Snippet
      |> where(id: ^id)
      |> Repo.update_all(inc: [views: 1])

      broadcast_change({:ok, %{id: id}}, [:snippet, :updated])
  end


  def like_snippet(snippet, user) do
    %Like{ snippet: snippet, user: %User{ username: user } }
    |> Repo.insert

    broadcast_change({:ok, %{id: snippet.id}}, [:snippet, :updated])
  end


  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(Snippetwiki.PubSub, @topic)
  end

  defp broadcast_change({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Snippetwiki.PubSub, @topic, {__MODULE__, event, result})

    {:ok, result}
  end

  defp broadcast_change({:error, message}, _) do
    {:error, message}
  end
end
