defmodule SnippetwikiWeb.PageControllerTest do
  use SnippetwikiWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == ~p"/users/log-in"
  end
end
