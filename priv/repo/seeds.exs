# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Snippetwiki.Repo.insert!(%Snippetwiki.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

user = Snippetwiki.Repo.insert!(%Snippetwiki.Snippets.User{email: "randomuser"})

snippet = Snippetwiki.Repo.insert!(%Snippetwiki.Snippets.Snippet{title: "Welcome"})
Snippetwiki.Repo.insert!(%Snippetwiki.Snippets.Snippet{title: "My second snippet"})

Snippetwiki.Repo.insert!(%Snippetwiki.Snippets.Revision{
  content: """
  [{"id":"185f550b-3bb3-4547-bf6f-d40b8cf7f7b2","type":"heading","props":{"backgroundColor":"default","textColor":"default","textAlignment":"left","level":1,"isToggleable":false},"content":[{"type":"text","text":"Hello","styles":{}}],"children":[]},{"id":"4a4775aa-ce89-4445-b5b5-3819bb8e9919","type":"paragraph","props":{"backgroundColor":"default","textColor":"default","textAlignment":"left"},"content":[{"type":"text","text":"Welcome to...","styles":{}}],"children":[]}]
  """,
  snippet: snippet
})

Snippetwiki.Repo.insert!(%Snippetwiki.Snippets.Revision{
  content: """
  [{"id":"185f550b-3bb3-4547-bf6f-d40b8cf7f7b2","type":"heading","props":{"backgroundColor":"default","textColor":"default","textAlignment":"left","level":1,"isToggleable":false},"content":[{"type":"text","text":"Hello, world!","styles":{}}],"children":[]},{"id":"4a4775aa-ce89-4445-b5b5-3819bb8e9919","type":"paragraph","props":{"backgroundColor":"default","textColor":"default","textAlignment":"left"},"content":[{"type":"text","text":"Welcome to SnippetWiki.","styles":{}}],"children":[]},{"id":"b87c790d-76ff-4e68-81cb-9b75cd96e968","type":"paragraph","props":{"backgroundColor":"default","textColor":"default","textAlignment":"left"},"content":[],"children":[]},{"id":"afc7820d-c646-40a7-b507-c85e6fa738ad","type":"paragraph","props":{"backgroundColor":"default","textColor":"default","textAlignment":"left"},"content":[{"type":"text","text":"This is the second revision.","styles":{}}],"children":[]}]
  """,
  snippet: snippet
})

Snippetwiki.Repo.insert!(%Snippetwiki.Snippets.Like{
  user: user,
  snippet: snippet
})


snippet = Snippetwiki.Repo.insert!(%Snippetwiki.Snippets.Snippet{bag: "Private", title: "Invisible snippet"})

Snippetwiki.Repo.insert!(%Snippetwiki.Snippets.Revision{
  content: """
  [{"id":"185f550b-3bb3-4547-bf6f-d40b8cf7f7b2","type":"heading","props":{"backgroundColor":"default","textColor":"default","textAlignment":"left","level":1,"isToggleable":false},"content":[{"type":"text","text":"Should not be visible","styles":{}}],"children":[]},{"id":"4a4775aa-ce89-4445-b5b5-3819bb8e9919","type":"paragraph","props":{"backgroundColor":"default","textColor":"default","textAlignment":"left"},"content":[{"type":"text","text":"Welcome to SnippetWiki.","styles":{}}],"children":[]},{"id":"b87c790d-76ff-4e68-81cb-9b75cd96e968","type":"paragraph","props":{"backgroundColor":"default","textColor":"default","textAlignment":"left"},"content":[],"children":[]},{"id":"afc7820d-c646-40a7-b507-c85e6fa738ad","type":"paragraph","props":{"backgroundColor":"default","textColor":"default","textAlignment":"left"},"content":[{"type":"text","text":"This is the second revision.","styles":{}}],"children":[]}]
  """,
  snippet: snippet
})
