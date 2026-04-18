#!/usr/bin/env bash
# notify.sh — Send a Telegram message via the Bot API.
#
# Usage: ./scripts/notify.sh "message text"
#
# Reads TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID from the environment, or from
# a .env file at the repo root if present. Markdown parse mode is enabled.
#
# Always exits 0 — failures print to stderr but never block the caller. This
# is deliberate: notification is a side-channel, not a hard dependency.

set -u

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Source .env if present, without leaking errors when it's missing.
if [ -f "$REPO_ROOT/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$REPO_ROOT/.env"
  set +a
fi

MSG="${1:-}"

if [ -z "$MSG" ]; then
  echo "notify.sh: no message provided" >&2
  exit 0
fi

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${TELEGRAM_CHAT_ID:-}" ]; then
  echo "notify.sh: TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID not set; skipping notification" >&2
  exit 0
fi

# Telegram caps messages at 4096 chars. Truncate with an ellipsis if longer.
MAX=4096
if [ "${#MSG}" -gt "$MAX" ]; then
  MSG="${MSG:0:$((MAX - 3))}..."
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "notify.sh: curl not found; skipping notification" >&2
  exit 0
fi

HTTP_CODE=$(curl -sS -o /tmp/notify-sh.out -w "%{http_code}" \
  -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
  --data-urlencode "text=${MSG}" \
  --data-urlencode "parse_mode=Markdown" 2>/dev/null || echo "000")

if [ "$HTTP_CODE" != "200" ]; then
  echo "notify.sh: Telegram API returned HTTP $HTTP_CODE" >&2
  [ -f /tmp/notify-sh.out ] && head -c 500 /tmp/notify-sh.out >&2 && echo "" >&2
fi

rm -f /tmp/notify-sh.out
exit 0
