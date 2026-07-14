defmodule SnippetwikiWeb.WikiragProxyTest do
  use SnippetwikiWeb.ConnCase

  describe "GET /wikirag/*" do
    test "redirects unauthenticated users to log in", %{conn: conn} do
      conn = get(conn, "/wikirag/embed.html")
      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end
end
