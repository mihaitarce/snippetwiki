defmodule Snwiki.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string
      add :bag_id, references(:bags, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create table(:revision_tags) do
      add :revision_id, references(:revisions, on_delete: :delete_all)
      add :tag_id, references(:tags, on_delete: :delete_all)
    end
  end
end
