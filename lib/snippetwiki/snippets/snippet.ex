defmodule Snippetwiki.Snippets.Snippet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "snippets" do
    field :title, :string
    field :namespace, :string
    field :bag, :string, default: "main"
    field :has_draft, :boolean, default: false
    field :views, :integer, default: 0
    has_many :revisions, Snippetwiki.Snippets.Revision
    has_many :likes, Snippetwiki.Snippets.Like

    field :content, :string, virtual: true
    field :content_type, :string, virtual: true
    field :like_count, :integer, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(snippet, attrs, user_scope) do
    snippet
    |> cast(attrs, [:title, :namespace, :has_draft, :views, :content])
    |> validate_required([:title])
    |> put_change(:bag, user_scope.user.bag)
    |> unique_constraint([:title, :bag, :namespace])
  end

  def create_unique_filename(filename) do
    extension = Path.extname(filename)
    basename = Path.basename(filename, extension)

    "#{basename}_#{IO.inspect Enum.to_list(?a..?f) ++ Enum.to_list(?0..?9) |> Enum.take_random(6)}#{extension}"
  end
end
