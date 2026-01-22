defmodule Snippetwiki.Repo.Migrations.CreateSnippets do
  use Ecto.Migration

  def change do
    create table(:snippets) do
      add :title, :string, null: false
      add :namespace, :string
      add :bag, :string, null: false
      add :has_draft, :boolean, default: false, null: false
      add :views, :integer, default: 0, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:snippets, [:title])
    create index(:snippets, [:namespace])

    create unique_index(:snippets, [:title, :bag, :namespace], nulls_distinct: false)
  end
end
