defmodule SnippetwikiWeb.PageController do
  use SnippetwikiWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
