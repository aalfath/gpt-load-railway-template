# Changelog

Each entry is one update of this template. Breaking changes are listed first.

## 1.4.14-1 (2026-11-19)

- README: Deploy on Railway button for the published template `gpt-load`. No change to the app or the image.

## 1.4.14 (2026-11-19)

- First release of the template: GPT-Load v1.4.14 (`ghcr.io/tbphp/gpt-load:v1.4.14@sha256:73b57783d102626186188e16efd09f09ac50c0d63229a1abdafa85d217b2974d`).
- One service built from this repo (a small `railway-start.sh` sets GPT-Load's App URL to `APP_URL` on first boot), SQLite and settings on a volume at `/app/data`, health check on `/health`.
- `AUTH_KEY` (admin login and first proxy key) and `ENCRYPTION_KEY` (encrypts stored API keys) are generated per deploy.
