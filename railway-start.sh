#!/bin/sh
# Railway wrapper for GPT-Load: start the app, then set its "App URL" setting
# (used to show each group's proxy endpoint) to APP_URL once, while the setting
# still holds the first-boot default (http://localhost:PORT or http://0.0.0.0:PORT).
# A value you later change under Settings is never overwritten.
set -e
PORT="${PORT:-3001}"
export PORT

if [ -n "$APP_URL" ] && [ -n "$AUTH_KEY" ]; then
  (
    base="http://127.0.0.1:${PORT}"
    i=0
    until curl -fsS -o /dev/null "$base/health"; do
      i=$((i + 1)); [ "$i" -gt 120 ] && exit 0; sleep 1
    done
    current=$(curl -fsS -H "Authorization: Bearer ${AUTH_KEY}" "$base/api/settings" \
      | jq -r '[.data[].settings[] | select(.key == "app_url") | .value][0] // empty') || exit 0
    case "$current" in
      http://localhost:*|http://0.0.0.0:*|http://127.0.0.1:*)
        if curl -fsS -o /dev/null -X PUT -H "Authorization: Bearer ${AUTH_KEY}" -H "Content-Type: application/json" \
             -d "$(jq -cn --arg u "${APP_URL%/}" '{app_url: $u}')" "$base/api/settings"; then
          echo "railway-start: App URL set to ${APP_URL%/}"
        fi ;;
    esac
  ) &
fi

exec /app/gpt-load
