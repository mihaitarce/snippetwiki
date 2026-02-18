# SnippetWiki

A collaborate wiki for short form content.

## Dependencies

Elixir, npm, Docker.


## Getting started

You will need to run these commands in separate terminals as they do not detach and log to stdout.

### 1) Database

```
docker compose up
```

Starts a postgres database on default port 5432 and an adminer (web-based database admin interface) on port 8080.

### 2) Caddy reverse proxy (for authentication)

```
caddy run --config Caddyfile -w
```

Redirects requests to http://localhost:2080 to the wiki web server, passing in authentication headers (user: caddy-user, group: caddy-group)

### 3) Wiki web server

To initialize database:
```
mix ecto.reset
```

To start the server:
```
mix phx.server
```

This will launch a server listening on http://localhost:4000, but since the server requires (header-based) authentication you will not be able to use it directly.

## TODO

- Menu bar is covered by other article cards

- Highlight like button if user has already liked it, unlike on second click

- Support referencing existing images/documents in document (right now images need to be uploaded directly in the editor)

- Talk page: nested conversations

## License

Copyright 2026 Mihai Tarce.
This software is licensed under the AGPLv3 license.