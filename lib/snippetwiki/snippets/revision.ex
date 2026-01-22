defmodule Snippetwiki.Snippets.Revision do
  use Ecto.Schema
  import Ecto.Changeset

  schema "revisions" do
    belongs_to :snippet, Snippetwiki.Snippets.Snippet
    many_to_many :authors, Snippetwiki.Snippets.User,
      join_through: Snippetwiki.Snippets.RevisionAuthor
    field :version, :integer
    field :content, :string
    field :content_type, :string, default: "application/vnd.blocknote+json"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(revision, attrs) do
    revision
    |> cast(attrs, [:content, :snippet_id, :authors])
    |> validate_required([:content, :snippet_id, :authors])
  end
end


defmodule Snippetwiki.Snippets.RevisionAuthor do
  use Ecto.Schema

  schema "revision_authors" do
    belongs_to :revision, Snippetwiki.Snippets.Revision
    belongs_to :author, Snippetwiki.Snippets.User
    timestamps()
  end
end
