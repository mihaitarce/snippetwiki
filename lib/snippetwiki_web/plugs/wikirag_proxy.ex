defmodule SnippetwikiWeb.Plugs.WikiragProxy do
  @moduledoc """
  Reverse-proxies the configured WikiRag mount path to the internal WikiRag service.

  Injects `X-Authenticated-User`, `X-Authenticated-Group`, and
  `X-Forwarded-Prefix` from the current scope so the iframe and API calls
  work without a separate Caddy route or query-param hacks.
  """
  @behaviour Plug

  import Plug.Conn

  require Logger

  @hop_by_hop ~w(
    connection
    keep-alive
    proxy-authenticate
    proxy-authorization
    te
    trailer
    transfer-encoding
    upgrade
  )

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    upstream = Application.fetch_env!(:snippetwiki, :wikirag_url)
    prefix = Application.fetch_env!(:snippetwiki, :wikirag_path)

    path = "/" <> Enum.join(conn.path_info, "/")
    query = if conn.query_string == "", do: "", else: "?" <> conn.query_string

    case request_method(conn.method) do
      {:ok, method} ->
        proxy_request(conn, upstream, prefix, path, query, method)

      :error ->
        conn
        |> send_resp(405, "Method Not Allowed")
        |> halt()
    end
  end

  defp proxy_request(conn, upstream, prefix, path, query, method) do
    target = upstream <> path <> query
    headers = proxy_request_headers(conn, prefix)
    body = read_request_body(conn)

    req_opts =
      [
        method: method,
        url: target,
        headers: headers,
        retry: false,
        # Pass bytes through untouched: no JSON-to-map decoding (send_resp
        # needs iodata) and no server-side redirect following.
        decode_body: false,
        redirect: false,
        receive_timeout: proxy_timeout()
      ]
      |> maybe_put_body(body)

    case Req.request(req_opts) do
      {:ok, %Req.Response{status: status, headers: resp_headers, body: resp_body}} ->
        conn
        |> merge_response_headers(resp_headers)
        |> send_resp(status, resp_body)
        |> halt()

      {:error, reason} ->
        Logger.warning("WikiRag proxy #{conn.method} #{path} failed: #{inspect(reason)}")

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(502, Jason.encode!(%{error: "WikiRag is unavailable"}))
        |> halt()
    end
  end

  defp maybe_put_body(opts, nil), do: opts
  defp maybe_put_body(opts, body), do: Keyword.put(opts, :body, body)

  defp read_request_body(conn) do
    case conn.assigns[:raw_body] do
      body when is_binary(body) and byte_size(body) > 0 ->
        body

      _ ->
        case read_body(conn) do
          {:ok, body, _} when byte_size(body) > 0 -> body
          _ -> nil
        end
    end
  end

  defp proxy_request_headers(conn, prefix) do
    scope = conn.assigns.current_scope
    user = scope.user.email
    group = Enum.join(scope.user.bags, ",")
    proxy_host = Application.get_env(:snippetwiki, :wikirag_proxy_host, "localhost")

    forwarded =
      conn.req_headers
      |> Enum.reject(fn {name, _} ->
        name = String.downcase(name)

        # "cookie" stays behind: WikiRag is authenticated purely via the
        # injected headers and must never see the Phoenix session cookie.
        name in @hop_by_hop or
          name in [
            "host",
            "cookie",
            "x-authenticated-user",
            "x-authenticated-group",
            "x-forwarded-prefix"
          ]
      end)

    [
      {"host", proxy_host},
      {"x-authenticated-user", user},
      {"x-authenticated-group", group},
      {"x-forwarded-prefix", prefix},
      {"accept-encoding", "identity"}
      | forwarded
    ]
  end

  # Req returns headers as %{name => [value, ...]}; flatten to tuples so
  # multi-value headers (set-cookie) survive. content-length is dropped
  # because send_resp/3 recomputes it for the body we actually send.
  defp merge_response_headers(conn, headers) do
    headers
    |> Enum.flat_map(fn
      {name, values} when is_list(values) -> Enum.map(values, &{String.downcase(name), &1})
      {name, value} -> [{String.downcase(name), value}]
    end)
    |> Enum.reject(fn {name, _} -> name in @hop_by_hop or name == "content-length" end)
    |> then(&merge_resp_headers(conn, &1))
  end

  defp proxy_timeout do
    Application.get_env(:snippetwiki, :wikirag_proxy_timeout, 120_000)
  end

  defp request_method(method) do
    case String.upcase(method) do
      "GET" -> {:ok, :get}
      "POST" -> {:ok, :post}
      "PUT" -> {:ok, :put}
      "PATCH" -> {:ok, :patch}
      "DELETE" -> {:ok, :delete}
      "HEAD" -> {:ok, :head}
      "OPTIONS" -> {:ok, :options}
      _ -> :error
    end
  end
end
