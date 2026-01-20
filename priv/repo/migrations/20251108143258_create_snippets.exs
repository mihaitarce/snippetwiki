defmodule Snippetwiki.Repo.Migrations.CreateSnippets do
  use Ecto.Migration

  def change do
    create table(:snippets) do
      add :title, :string, null: false
      add :namespace, :string
      add :has_draft, :boolean, default: false, null: false
      add :views, :integer, default: 0, null: false

      add :bag_id, references(:bags, on_delete: :delete_all)
      # remove
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:snippets, [:namespace])
    create index(:snippets, [:bag_id])

    create unique_index(:snippets, [:title, :bag_id], where: "namespace IS NULL", name: "snippets_snippet_title_bag_id_index")
    create unique_index(:snippets, [:title, :bag_id], where: "namespace LIKE 'File'", name: "snippets_file_title_bag_id_index")
  end
end
