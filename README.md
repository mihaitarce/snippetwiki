# SnippetWiki + WikiRag

A collaborative wiki for short-form content with RAG-powered search via WikiRag.

## Quick start

### 1. Initialize WikiRag submodule

```bash
git submodule update --init --recursive
```

### 2. Configure `wikirag/.env`

```bash
cp wikirag/.env.example wikirag/.env
```

Edit `wikirag/.env` for your environment:

| Section | Key settings | Notes |
|---------|--------------|-------|
| **Wiki** | `SNIPPETWIKI_URL`, `POSTGRES_*` | WikiRag reads snippets from Postgres (not HTTP). `SNIPPETWIKI_URL` is only for citation links shown to users. |
| **LLM** | `LLM_PROVIDER`, `VLLM_*` / `OLLAMA_*` | See `wikirag/README.md`. Ensure the shared LLM service (portfolio-ai) is running. |
| **Admin** | `ADMIN_USERNAME`, `ADMIN_PASSWORD` | Password must be a bcrypt hash See `wikirag/README.md` |
| **Rebuild** | `REBUILD_ENABLED`, `REBUILD_CRON` | Cron job rebuilds the vector index, default Sunday 3am (`wikirag-cron` service) |

### 3. Start the stack

```    
docker network create snippetwiki-net
docker compose up --build
```

Before starting, update the public URL settings in `docker-compose.yml` (`app` → `environment`) for your deployment:

| Variable | Purpose |
|----------|---------|
| `PHX_HOST` | Public hostname users access (domain or `localhost`) |
| `PHX_PATH` | Subpath where the wiki is mounted (e.g. `/wiki` or `/`) |
| `WIKIRAG_URL` | WikiRag base URL; the Ask/Search tab loads `{WIKIRAG_URL}embed.html` |

This starts Postgres on port 5432, Adminer (web-based database admin) on port 8080, and the wiki app on port 4000. Database migrations run automatically when the app container starts.

To initialize the database from scratch (WARNING: deletes all content!), with Postgres running:

```
mix ecto.reset
```

### 4. Caddy reverse proxy (for authentication)

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