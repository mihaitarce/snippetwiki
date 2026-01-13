defmodule SnippetwikiWeb.SnippetLiveTest do
  use SnippetwikiWeb.ConnCase

  import Phoenix.LiveViewTest
  import Snippetwiki.SnippetsFixtures

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}
  defp create_snippet(_) do
    snippet = snippet_fixture()

    %{snippet: snippet}
  end

  describe "Index" do
    setup [:create_snippet]

    test "lists all snippets", %{conn: conn, snippet: snippet} do
      {:ok, _index_live, html} = live(conn, ~p"/snippets")

      assert html =~ "Listing Snippets"
      assert html =~ snippet.title
    end

    test "saves new snippet", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/snippets")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Snippet")
               |> render_click()
               |> follow_redirect(conn, ~p"/snippets/new")

      assert render(form_live) =~ "New Snippet"

      assert form_live
             |> form("#snippet-form", snippet: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#snippet-form", snippet: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/snippets")

      html = render(index_live)
      assert html =~ "Snippet created successfully"
      assert html =~ "some title"
    end

    test "updates snippet in listing", %{conn: conn, snippet: snippet} do
      {:ok, index_live, _html} = live(conn, ~p"/snippets")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#snippets-#{snippet.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/snippets/#{snippet}/edit")

      assert render(form_live) =~ "Edit Snippet"

      assert form_live
             |> form("#snippet-form", snippet: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#snippet-form", snippet: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/snippets")

      html = render(index_live)
      assert html =~ "Snippet updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes snippet in listing", %{conn: conn, snippet: snippet} do
      {:ok, index_live, _html} = live(conn, ~p"/snippets")

      assert index_live |> element("#snippets-#{snippet.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#snippets-#{snippet.id}")
    end
  end

  describe "Show" do
    setup [:create_snippet]

    test "displays snippet", %{conn: conn, snippet: snippet} do
      {:ok, _show_live, html} = live(conn, ~p"/snippets/#{snippet}")

      assert html =~ "Show Snippet"
      assert html =~ snippet.title
    end

    test "updates snippet and returns to show", %{conn: conn, snippet: snippet} do
      {:ok, show_live, _html} = live(conn, ~p"/snippets/#{snippet}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/snippets/#{snippet}/edit?return_to=show")

      assert render(form_live) =~ "Edit Snippet"

      assert form_live
             |> form("#snippet-form", snippet: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#snippet-form", snippet: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/snippets/#{snippet}")

      html = render(show_live)
      assert html =~ "Snippet updated successfully"
      assert html =~ "some updated title"
    end
  end
end
