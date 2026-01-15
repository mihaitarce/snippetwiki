defmodule Snippetwiki.Snippets.Revision do
  use Ecto.Schema
  import Ecto.Changeset

  schema "revisions" do
    belongs_to :snippet, Snippetwiki.Snippets.Snippet
    many_to_many :authors, Snippetwiki.Snippets.User,
      join_through: Snippetwiki.Snippets.RevisionAuthor
    many_to_many :tags, Snippetwiki.Snippets.Tag,
      join_through: Snippetwiki.Snippets.RevisionTag
    field :version, :integer
    field :content, :string
    field :content_type, :string, default: "text/html"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(revision, attrs) do
    revision
    |> cast(attrs, [:content, :snippet_id, :author_id])
    |> validate_required([:content, :snippet_id, :author_id])
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


defmodule Snippetwiki.Snippets.RevisionTag do
  use Ecto.Schema

  schema "revision_tags" do
    belongs_to :revision, Snippetwiki.Snippets.Revision
    belongs_to :tag, Snippetwiki.Snippets.Tag
    timestamps()
  end
end
