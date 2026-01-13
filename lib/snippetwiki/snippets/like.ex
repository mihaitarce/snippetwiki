defmodule Snippetwiki.Snippets.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    belongs_to :snippet, Snippetwiki.Snippets.Snippet
    belongs_to :user, Snippetwiki.Snippets.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [])
    |> validate_required([])
  end
end
