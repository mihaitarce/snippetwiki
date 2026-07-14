defmodule Snippetwiki.WikiragIndexer do
  @moduledoc """
  Fire-and-forget incremental reindexing of snippets in WikiRag.

  Calls WikiRag's `POST /api/index` after a snippet's content changes or the
  snippet is deleted, so Ask/Search stays fresh without waiting for the
  nightly full rebuild, and never blocks or fails the calling operation.
  """

  require Logger

  @doc """
  Asynchronously reindex `snippet` in its bag. WikiRag re-reads the latest
  revision from Postgres, so this also handles deletes (no revision found
  means the snippet's chunks are just removed).
  """
  def reindex(%{id: id, bag: bag}) when is_integer(id) and is_binary(bag) do
    if base = Application.get_env(:snippetwiki, :wikirag_url) do
      url = base <> "/api/index"

      Task.Supervisor.start_child(Snippetwiki.TaskSupervisor, fn ->
        case Req.post(url,
               json: %{snippet_id: id, bag: bag},
               headers: [{"x-authenticated-user", "wikirag-admin"}],
               retry: false
             ) do
          {:ok, %Req.Response{status: 200}} ->
            :ok

          {:ok, %Req.Response{status: status, body: body}} ->
            Logger.warning("WikiRag reindex of snippet #{id} failed: #{status} #{inspect(body)}")

          {:error, reason} ->
            Logger.warning("WikiRag reindex of snippet #{id} failed: #{inspect(reason)}")
        end
      end)
    end

    :ok
  end

  def reindex(_snippet), do: :ok
end
