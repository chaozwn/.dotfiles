#!/usr/bin/env bash
# stdin is an image/png clipboard payload. If Flameshot just saved a screenshot,
# replace the clipboard with that file path so a terminal paste can carry it.
set -euo pipefail

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
cat >"$tmp"
if [[ ! -s "$tmp" ]]; then
  exit 0
fi

shot_dir="${HOME}/Screenshots"
newest=$(find "$shot_dir" -maxdepth 1 -type f -name '*.png' -mmin -0.083 -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2- || true)
if [[ -z "${newest:-}" || ! -f "$newest" ]]; then
  exit 0
fi

printf '%s' "$newest" | wl-copy --type text/plain
