#!/bin/sh
set -e

RELEASE_BIN="_build/prod/rel/snippetwiki/bin/snippetwiki"

$RELEASE_BIN eval '
  Application.load(:snippetwiki)
  for repo <- Application.fetch_env!(:snippetwiki, :ecto_repos) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
  end
'

exec $RELEASE_BIN start