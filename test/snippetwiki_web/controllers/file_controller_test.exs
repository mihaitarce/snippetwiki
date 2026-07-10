defmodule SnippetwikiWeb.FileControllerTest do
  use SnippetwikiWeb.ConnCase

  alias Snippetwiki.Snippets

  setup :register_and_log_in_user

  defp create_file(scope, title, content, content_type) do
    {:ok, snippet} = Snippets.create_snippet(scope, %{title: title, namespace: "File"})

    {:ok, snippet} = Snippets.create_new_revision(scope, snippet, %{}, content, content_type)

    snippet
  end

  test "serves image types inline", %{conn: conn, scope: scope} do
    create_file(scope, "photo.png", <<137, 80, 78, 71>>, "image/png")

    conn = get(conn, ~p"/files/photo.png")

    assert response(conn, 200)
    assert hd(get_resp_header(conn, "content-disposition")) =~ "inline"
    assert hd(get_resp_header(conn, "content-type")) =~ "image/png"
  end

  test "forces attachment for types that could execute on the app origin", %{
    conn: conn,
    scope: scope
  } do
    create_file(scope, "evil.html", "<script>alert(1)</script>", "text/html")

    conn = get(conn, ~p"/files/evil.html")

    assert response(conn, 200)
    assert hd(get_resp_header(conn, "content-disposition")) =~ "attachment"
  end
end
