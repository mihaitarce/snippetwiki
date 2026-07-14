defmodule SnippetwikiWeb.SnippetWikiLiveTest do
  use SnippetwikiWeb.ConnCase

  import Phoenix.LiveViewTest
  import Snippetwiki.SnippetsFixtures

  alias Snippetwiki.Snippets

  setup :register_and_log_in_user

  defp create_article(%{scope: scope}) do
    %{snippet: snippet_fixture(scope, %{title: "Wiki article", has_draft: false})}
  end

  defp bag(%{scope: scope}), do: %{bag: scope.user.bag}

  describe "app shell" do
    setup [:create_article, :bag]

    test "renders header, sidebar, article stream, ask panel and mobile nav", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#wiki-header")
      assert has_element?(view, "#user-menu")
      assert has_element?(view, "#wiki-sidebar")
      assert has_element?(view, "#article-stream")
      assert has_element?(view, "#ask-panel")
      assert has_element?(view, "#wikirag-embed")
      assert has_element?(view, "#mobile-nav")
      assert has_element?(view, "#sidebar-resizer")
      assert has_element?(view, "#ask-resizer")
    end

    test "header shows the signed-in user's full name", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert view |> element("#user-menu") |> render() =~ user.email
      refute has_element?(view, "#user-menu a")
    end

    test "toggling the Ask panel keeps the iframe mounted", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#wikirag-embed")

      view |> element("#ask-toggle") |> render_click()
      assert has_element?(view, "#wikirag-embed")

      view |> element("#ask-toggle") |> render_click()
      assert has_element?(view, "#wikirag-embed")
    end

    test "mobile view switching accepts the ask view", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html = view |> element(~s{#mobile-nav button[phx-value-view="ask"]}) |> render_click()
      assert html =~ "mobile-nav"
    end
  end

  describe "sidebar" do
    setup [:create_article, :bag]

    test "opens and closes an article from Contents", %{conn: conn, snippet: snippet, bag: bag} do
      {:ok, view, _html} = live(conn, ~p"/")

      refute has_element?(view, "#snippet-#{snippet.id}")

      view |> element(~s{#wiki-sidebar button[phx-value-bag="#{bag}"]}) |> render_click()
      view |> element("#toc-#{bag}-#{snippet.id} button") |> render_click()

      assert has_element?(view, "#snippet-#{snippet.id}")
      assert view |> element("#open-section") |> render() =~ snippet.title

      view |> element(~s{#open-section button[phx-click="close_snippet"]}) |> render_click()

      refute has_element?(view, "#snippet-#{snippet.id}")
      refute has_element?(view, "#open-section")
    end

    test "close all closes every open article", %{
      conn: conn,
      scope: scope,
      snippet: snippet,
      bag: bag
    } do
      other = snippet_fixture(scope, %{title: "Another article", has_draft: false})

      {:ok, view, _html} = live(conn, ~p"/")

      view |> element(~s{#wiki-sidebar button[phx-value-bag="#{bag}"]}) |> render_click()
      view |> element("#toc-#{bag}-#{snippet.id} button") |> render_click()

      assert has_element?(view, "#open-section")

      view |> element(~s{#open-section button[phx-click="close_snippets"]}) |> render_click()

      refute has_element?(view, "#open-section")
      refute has_element?(view, "#snippet-#{snippet.id}")
      refute has_element?(view, "#snippet-#{other.id}")
    end

    test "switches between contents, recent and files modes", %{
      conn: conn,
      scope: scope,
      snippet: snippet,
      bag: bag
    } do
      file = Snippets.create_snippet(scope, %{title: "doc.pdf", namespace: "File"}) |> elem(1)

      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#sidebar-mode-contents")

      view |> element("#sidebar-mode-recent") |> render_click()
      assert has_element?(view, "#recent-#{snippet.id}")

      view |> element("#sidebar-mode-files") |> render_click()
      view |> element(~s{#wiki-sidebar button[phx-value-bag="#{bag}"]}) |> render_click()
      assert has_element?(view, "#files-#{bag}-#{file.id}")
    end

    test "lists a draft and resumes editing from it", %{conn: conn, scope: scope} do
      draft = snippet_fixture(scope, %{title: "Draft article", has_draft: true})

      {:ok, view, _html} = live(conn, ~p"/")

      assert view |> element("#drafts-section") |> render() =~ draft.title

      view |> element("#draft-#{draft.id} button") |> render_click()

      assert has_element?(view, "#snippet-#{draft.id} form")
    end
  end

  describe "restoring a session" do
    setup [:create_article]

    test "restore_open reopens known articles without counting views", %{
      conn: conn,
      scope: scope,
      snippet: snippet
    } do
      {:ok, view, _html} = live(conn, ~p"/")

      render_hook(view, "restore_open", %{"ids" => [snippet.id, 999_999, "bogus", nil]})

      assert has_element?(view, "#snippet-#{snippet.id}")
      assert Snippets.get_snippet!(scope, snippet.id).views == snippet.views
    end

    test "a restored session takes precedence over the Welcome fallback", %{
      conn: conn,
      scope: scope,
      snippet: snippet
    } do
      welcome = snippet_fixture(scope, %{title: "Welcome", has_draft: false})

      {:ok, view, _html} = live(conn, ~p"/")

      render_hook(view, "restore_open", %{"ids" => [snippet.id]})

      assert has_element?(view, "#snippet-#{snippet.id}")
      refute has_element?(view, "#snippet-#{welcome.id}")
    end

    test "an empty saved session falls back to the Welcome article", %{
      conn: conn,
      scope: scope
    } do
      welcome = snippet_fixture(scope, %{title: "Welcome", has_draft: false})

      {:ok, view, _html} = live(conn, ~p"/")
      refute has_element?(view, "#snippet-#{welcome.id}")

      render_hook(view, "restore_open", %{"ids" => []})

      assert has_element?(view, "#snippet-#{welcome.id}")
    end
  end

  describe "component flashes" do
    setup [:create_article]

    test "saving a snippet surfaces the success flash on the LiveView", %{
      conn: conn,
      snippet: snippet
    } do
      {:ok, view, _html} = live(conn, ~p"/")

      render_hook(view, "restore_open", %{"ids" => [snippet.id]})
      view |> element("#snippet-#{snippet.id} button[phx-click=edit_snippet]") |> render_click()

      view
      |> element("#snippet-#{snippet.id} form")
      |> render_submit(%{"snippet" => %{"title" => "Renamed article", "content" => "[]"}})

      assert render(view) =~ "Snippet updated successfully"
    end
  end

  describe "open_initial" do
    setup [:create_article, :bag]

    test "opens the article from the provided bag", %{
      conn: conn,
      snippet: snippet,
      bag: bag
    } do
      {:ok, view, _html} = live(conn, ~p"/")

      render_hook(view, "open_initial", %{"value" => %{"title" => snippet.title, "bag" => bag}})

      assert has_element?(view, "#snippet-#{snippet.id}")
    end

    test "unknown title in a known bag prompts creation", %{conn: conn, bag: bag} do
      {:ok, view, _html} = live(conn, ~p"/")

      render_hook(view, "open_initial", %{"value" => %{"title" => "Ghost article", "bag" => bag}})

      assert view |> element("#missing-article-modal") |> render() =~ "Ghost article"
    end
  end

  describe "empty articles" do
    setup [:create_article]

    test "an empty BlockNote document shows the Empty snippet placeholder", %{
      conn: conn,
      scope: scope,
      snippet: snippet
    } do
      empty_doc = ~s([{"id":"a","type":"paragraph","props":{},"content":[],"children":[]}])
      {:ok, _} = Snippets.create_new_revision(scope, snippet, %{}, empty_doc)

      {:ok, view, _html} = live(conn, ~p"/")
      render_hook(view, "restore_open", %{"ids" => [snippet.id]})

      assert view |> element("#snippet-#{snippet.id}") |> render() =~ "Empty snippet"
    end
  end

  describe "deep links" do
    setup [:create_article, :bag]

    test "opens an existing article via /contents/:scope/:title", %{
      conn: conn,
      snippet: snippet,
      bag: bag
    } do
      {:ok, view, _html} = live(conn, ~p"/contents/#{bag}/#{snippet.title}")

      assert has_element?(view, "#snippet-#{snippet.id}")
    end

    test "shows the missing article modal and creates the article", %{conn: conn, bag: bag} do
      {:ok, view, _html} = live(conn, ~p"/contents/#{bag}/Never written")

      assert view |> element("#missing-article-modal") |> render() =~ "Never written"

      view
      |> element(~s{#missing-article-modal button[phx-click="create_missing_snippet"]})
      |> render_click()

      refute has_element?(view, "#missing-article-modal")
      assert view |> element("#article-stream form") |> render() =~ "Never written"
    end

    test "titles with percent signs survive deep linking undamaged", %{
      conn: conn,
      scope: scope,
      bag: bag
    } do
      crashy = snippet_fixture(scope, %{title: "50% off", has_draft: false})
      encoded = snippet_fixture(scope, %{title: "Test%20name", has_draft: false})

      {:ok, view, _html} = live(conn, ~p"/contents/#{bag}/#{crashy.title}")
      assert has_element?(view, "#snippet-#{crashy.id}")

      {:ok, view, _html} = live(conn, ~p"/contents/#{bag}/#{encoded.title}")
      assert has_element?(view, "#snippet-#{encoded.id}")
      refute has_element?(view, "#missing-article-modal")
    end

    test "dismissing the missing article modal keeps the wiki usable", %{conn: conn, bag: bag} do
      {:ok, view, _html} = live(conn, ~p"/contents/#{bag}/Never written")

      view
      |> element(~s{#missing-article-modal button.btn-ghost})
      |> render_click()

      refute has_element?(view, "#missing-article-modal")
      assert has_element?(view, "#article-stream")
    end
  end

  describe "creating content" do
    test "new snippet opens in edit mode", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element(~s{#add-dropdown-menu li button}, "New snippet") |> render_click()

      assert view |> element("#article-stream form") |> render() =~ "New snippet 1"
    end

    test "duplicate file names are rejected during upload validation", %{
      conn: conn,
      scope: scope
    } do
      {:ok, _file} = Snippets.create_snippet(scope, %{title: "photo.jpg", namespace: "File"})

      {:ok, view, _html} = live(conn, ~p"/")

      input =
        file_input(view, "#upload", :documents, [
          %{
            name: "photo.jpg",
            content: <<255, 216, 255>>,
            type: "image/jpeg"
          }
        ])

      assert {:ok, %{ref: _}} = preflight_upload(input)

      assert view |> element("#upload") |> render_change() =~ "File name already exists"
    end
  end
end
