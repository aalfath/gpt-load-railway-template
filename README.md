# GPT-Load on Railway

A one-service [Railway](https://railway.com) template for [GPT-Load](https://www.gpt-load.com/v1), the self-hosted AI API proxy by [tbphp](https://github.com/tbphp/gpt-load). It keeps pools of upstream API keys for OpenAI, Gemini and Anthropic-format services, rotates and load-balances them, blacklists failing keys, and logs every request.

## What it deploys

| Service | Source | Version | Storage |
|---|---|---|---|
| `GPT-Load` | this repo's `Dockerfile` | GPT-Load **1.4.14** (`ghcr.io/tbphp/gpt-load:v1.4.14@sha256:73b57783…2974d`) | volume on `/app/data` |

- Public HTTPS domain on port 3001, health check `GET /health`, restart on failure.
- GPT-Load keeps its SQLite database (`/app/data/gpt-load.db`) on the volume, so groups, keys, settings and request logs survive redeploys and updates.
- `railway-start.sh` starts GPT-Load and, once, replaces the first-boot App URL (`http://localhost:3001`) with `APP_URL`. If you change App URL under **Settings** later, it's left alone.
- Without `REDIS_DSN` it uses its in-memory cache, which is fine for a single instance.
- This is the stable 1.x line. GPT-Load 2.0 is still a release candidate; the template moves to it once 2.0 is stable.

## Variables

| Variable | Default | Why |
|---|---|---|
| `AUTH_KEY` | generated, 40 characters | The admin key: you log in to the web UI with it, and it's the first global proxy key |
| `ENCRYPTION_KEY` | generated, 64 characters | Encrypts the upstream API keys stored in the database. Keep it: if it's lost, the stored keys can't be decrypted |
| `APP_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL. On first boot the start script saves it as GPT-Load's **App URL** setting, which the UI uses to show each group's proxy endpoint |
| `PORT` | `3001` | Port GPT-Load listens on; the Railway domain targets it |

There's no default password. Find `AUTH_KEY` in the service's **Variables** tab after the deploy and use it to log in.

Optional settings, not in the template: `DATABASE_DSN` (MySQL or PostgreSQL instead of SQLite), `REDIS_DSN` (needed for several nodes), `MAX_CONCURRENT_REQUESTS`, CORS (`ENABLE_CORS`, `ALLOWED_ORIGINS`) and logging (`LOG_LEVEL`, `LOG_FORMAT`). See the upstream [configuration reference](https://github.com/tbphp/gpt-load#configuration-system). Add them on the service if you need them.

## Using it

1. Open your domain and log in with `AUTH_KEY`.
2. Create a group (for example `openai`, channel type OpenAI, upstream `https://api.openai.com`) and add your API keys to it.
3. Point your client at `https://YOUR-DOMAIN/proxy/openai/v1` and authenticate with a proxy key (the global one is `AUTH_KEY` until you change it under **Settings**; you can also set group-level proxy keys).

## Updates

The service builds from this repo's `main` branch. When a new GPT-Load release is pinned here, Railway shows deployers an "update available" notice, and you choose when to apply it. Read [`CHANGELOG.md`](CHANGELOG.md) first: breaking changes are listed at the top of each entry.

## Run it locally

```sh
docker build -t gpt-load-railway .
docker run -p 3001:3001 -e APP_URL=http://localhost:3001 -e AUTH_KEY=change-me-to-a-long-random-string -e ENCRYPTION_KEY=another-long-random-string -v gpt-load-data:/app/data gpt-load-railway
```

GPT-Load is MIT licensed by its authors. This repo only packages it for Railway.
