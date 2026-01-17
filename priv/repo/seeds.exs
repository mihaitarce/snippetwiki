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

user = Snippetwiki.Repo.insert!(%Snippetwiki.Snippets.User{email: "mihai"})

snippet = Snippetwiki.Repo.insert!(%Snippetwiki.Snippets.Snippet{user_id: user.id, title: "Welcome"})
Snippetwiki.Repo.insert!(%Snippetwiki.Snippets.Snippet{user_id: user.id, title: "My second snippet"})

Snippetwiki.Repo.insert!(%Snippetwiki.Snippets.Revision{
  content: "# Heading\nSome initial content here...",
  snippet: snippet
})

Snippetwiki.Repo.insert!(%Snippetwiki.Snippets.Revision{
  content: "# Heading\nSome newer content here...",
  snippet: snippet
})

Snippetwiki.Repo.insert!(%Snippetwiki.Snippets.Like{
  user: user,
  snippet: snippet
})
