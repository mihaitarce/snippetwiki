defmodule Snippetwiki.Snippets.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    belongs_to :bag, Snippetwiki.Snippets.Bag

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bag, attrs) do
    bag
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
