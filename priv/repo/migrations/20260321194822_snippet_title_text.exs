defmodule Snippetwiki.Repo.Migrations.SnippetTitleText do
  use Ecto.Migration

  def change do
    alter table(:snippets) do
      modify :title, :text
    end
  end
end
