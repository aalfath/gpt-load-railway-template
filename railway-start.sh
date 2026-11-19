#!/bin/sh
# Railway wrapper for GPT-Load: start the app, then set its "App URL" setting
# (used to show each group's proxy endpoint) to APP_URL once, while the setting
# still holds the first-boot default (http://localhost:PORT or http://0.0.0.0:PORT).
# A value you later change under Settings is never overwritten.
# Uses only BusyBox tools from the base image (wget, nc, sed, grep).
PORT="${PORT:-3001}"
export PORT

set_app_url() {
  base="http://127.0.0.1:${PORT}"
  i=0
  until wget -q -T 5 -O /dev/null "$base/health" 2>/dev/null; do
    i=$((i + 1)); [ "$i" -gt 120 ] && return 0; sleep 1
  done
  current=$(wget -q -T 10 -O - --header "Authorization: Bearer ${AUTH_KEY}" "$base/api/settings" 2>/dev/null \
    | grep -o '"key":"app_url"[^}]*' | sed -n 's/.*"value":"\([^"]*\)".*/\1/p' | head -n 1)
  case "$current" in
    http://localhost:*|http://0.0.0.0:*|http://127.0.0.1:*) ;;
    *) return 0 ;;
  esac
  url="${APP_URL%/}"
  body="{\"app_url\":\"${url}\"}"
  len=$(printf '%s' "$body" | wc -c)
  status=$(printf 'PUT /api/settings HTTP/1.0\r\nHost: 127.0.0.1\r\nAuthorization: Bearer %s\r\nContent-Type: application/json\r\nContent-Length: %s\r\nConnection: close\r\n\r\n%s' \
      "$AUTH_KEY" "$len" "$body" | timeout 15 nc 127.0.0.1 "$PORT" 2>/dev/null | head -n 1)
  case "$status" in
    *" 200"*) echo "railway-start: App URL set to ${url}" ;;
    *) echo "railway-start: could not set App URL (${status:-no response}); set it under Settings" ;;
  esac
}

case "$APP_URL" in
  http://*|https://*) [ -n "$AUTH_KEY" ] && set_app_url & ;;
esac

exec /app/gpt-load
