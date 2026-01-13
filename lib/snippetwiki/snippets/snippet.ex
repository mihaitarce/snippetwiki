defmodule Snippetwiki.Snippets.Snippet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "snippets" do
    field :title, :string
    field :has_draft, :boolean
    field :views, :integer, default: 0
    belongs_to :bag, Snippetwiki.Snippets.Bag
    has_many :revisions, Snippetwiki.Snippets.Revision
    has_many :likes, Snippetwiki.Snippets.Like

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(snippet, attrs) do
    snippet
    |> cast(attrs, [:title, :has_draft])
    |> validate_required([:title])
  end
end
