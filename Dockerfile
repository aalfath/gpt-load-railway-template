# GPT-Load for Railway: the official image, pinned by version and digest.
# https://github.com/tbphp/gpt-load (v1.x stable line)
FROM ghcr.io/tbphp/gpt-load:v1.4.14@sha256:73b57783d102626186188e16efd09f09ac50c0d63229a1abdafa85d217b2974d

# curl and jq for the start script's one-time "App URL" setting.
RUN apk add --no-cache curl jq

# Fixed settings. Railway sets PORT; the app reads PORT and HOST itself.
# SQLite (./data/gpt-load.db) lives under /app/data, which the template mounts as a volume.
ENV HOST=0.0.0.0 \
    PORT=3001 \
    TZ=UTC

WORKDIR /app
RUN mkdir -p /app/data
COPY --chmod=755 railway-start.sh /app/railway-start.sh
EXPOSE 3001
ENTRYPOINT ["/app/railway-start.sh"]
