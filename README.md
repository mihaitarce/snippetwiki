# SnippetWiki + WikiRag

A collaborative wiki for short-form content with RAG-powered search via WikiRag.

## Getting started

### 1) Initialize & Config WikiRag submodule

```bash
git submodule update --init --recursive
cp wikirag/.env.example wikirag/.env
```

Edit `wikirag/.env` for your environment:
| Variable                           | Description                                                                                                 |
|------------------------------------|-------------------------------------------------------------------------------------------------------------|
| `SNIPPETWIKI_URL`                  | Base URL for SnippetWiki (e.g. `http://localhost:2080`).                                                    |
| `LLM_PROVIDER`, `VLLM_*`, `OLLAMA_*` | LLM backend and model/config options.                                                                       |
| `ADMIN_PASSWORD`                   | Bcrypt hash for admin login. <br>Generate with:<br>`python -c "import bcrypt; print(bcrypt.hashpw(b'your-password', bcrypt.gensalt()).decode())"` |
| `REBUILD_ENABLED`, `REBUILD_CRON`  | Enable and schedule automatic embedding rebuilds.  

### 2) Start Wiki web server

```    
cp .env.example .env
docker network create snippetwiki-net
docker compose up --build
```

Edit `.env` for your environment:

| Variable           | Description                                 |
|--------------------|---------------------------------------------|
| `POSTGRES_DATA`    | Path to Postgres data directory             |
| `SECRET_KEY_BASE`  | Phoenix secret key (generate with `mix phx.gen.secret`) |
| `PHX_HOST`         | Hostname for the Phoenix server             |
| `PHX_PATH`         | Deployment path for the Phoenix app (`/`)   |
| `WIKIRAG_URL` | WikiRag base URL; the Ask/Search tab loads `{WIKIRAG_URL}embed.html` |

This will start the following services: Postgres on port 5432, Adminer (web-based database admin) on port 8080, the wiki app on port 4000. Database migrations for the wiki app will run automatically when the app container starts.

The wiki server (http://localhost:4000) requires (header-based) authentication you will not be able to use it directly.

### 3) Caddy reverse proxy (for authentication)

```
caddy run --config Caddyfile -w
```

Redirects requests to http://localhost:2080 to the wiki web server, passing in authentication headers (user: caddy-user, group: caddy-group)

## TODO

- Highlight like button if user has already liked it, unlike on second click

- Support referencing existing images/documents in document (right now images need to be uploaded directly in the editor)

- Talk page: nested conversations

## License

Copyright 2026 Mihai Tarce.
This software is licensed under the AGPLv3 license.