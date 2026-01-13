defmodule Snwiki.Repo.Migrations.CreateRevisions do
  use Ecto.Migration

  def change do
    create table(:revisions) do
      add :snippet_id, references(:snippets, on_delete: :delete_all)
      add :author_id, references(:users, on_delete: :nothing)
      add :version, :serial
      add :content, :bytea
      add :content_type, :string

      timestamps(type: :utc_datetime)
    end

    create index(:revisions, [:snippet_id])
    create index(:revisions, [:author_id])

    create table(:revision_authors) do
      add :revision_id, references(:revisions, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
