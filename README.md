# SnippetWiki

A collaborate wiki for short form content.

## Dependencies

Elixir, npm, Docker.


## Getting started

You will need to run these commands in separate terminals as they do not detach and log to stdout.

### 1) Database and wiki app

```
docker compose up --build
```

Starts Postgres on port 5432, Adminer (web-based database admin) on port 8080, and the wiki app on port 4000. Database migrations run automatically when the app container starts.

Rebuild after code changes:

```
docker compose up --build
```

To initialize the database from scratch (WARNING: deletes all content!), with Postgres running:

```
mix ecto.reset
```

### 2) Caddy reverse proxy (for authentication)

```
caddy run --config Caddyfile -w
```

Proxies http://localhost:2080 to the wiki app, passing in authentication headers (user: caddy-user, group: caddy-group).

Use the wiki at **http://localhost:2080**. Port 4000 is exposed for the app directly, but the server requires header-based authentication so you cannot use it without Caddy.

## TODO

- Menu bar is covered by other article cards

- Highlight like button if user has already liked it, unlike on second click

- Support referencing existing images/documents in document (right now images need to be uploaded directly in the editor)

- Talk page: nested conversations

## License

Copyright 2026 Mihai Tarce.
This software is licensed under the AGPLv3 license.