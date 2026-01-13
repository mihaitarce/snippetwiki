defmodule Snippetwiki.Snippets.Bag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bags" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bag, attrs) do
    bag
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
