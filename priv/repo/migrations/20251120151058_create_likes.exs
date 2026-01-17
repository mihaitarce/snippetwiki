defmodule Snippetwiki.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :snippet_id, references(:snippets, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:likes, [:snippet_id])
    create index(:likes, [:user_id])

    create unique_index(:likes, [:snippet_id, :user_id])
  end
end
