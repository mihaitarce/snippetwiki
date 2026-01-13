defmodule Snippetwiki.Repo.Migrations.CreateBags do
  use Ecto.Migration

  def change do
    create table(:bags) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
