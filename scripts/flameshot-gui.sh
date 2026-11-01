#!/usr/bin/env bash
# Pick one monitor, capture only that monitor, and open the editor there.
# slurp -o -r draws a box on each output; click the screen to capture.
set -euo pipefail

output=$(slurp -o -r -f '%o' </dev/null | tr -d '\n') || exit 0
if [[ -z "$output" || "$output" == "<unknown>" ]]; then
  exit 0
fi

request="${XDG_RUNTIME_DIR:-/tmp}/flameshot-output"
printf '%s\n' "$output" >"$request"
niri msg action focus-monitor "$output" || true

before=$(niri msg --json windows | /usr/bin/python3 -c '
import json, sys
windows = json.load(sys.stdin)
print(" ".join(str(w["id"]) for w in windows if w.get("app_id") == "flameshot"))
')

(
  for _ in $(seq 1 40); do
    id=$(niri msg --json windows | /usr/bin/python3 -c '
import json, sys
before = set(sys.argv[1].split())
windows = json.load(sys.stdin)
fresh = [
    w for w in windows
    if w.get("app_id") == "flameshot"
    and w.get("title") != "flameshot-pin"
    and str(w.get("id")) not in before
]
if not fresh:
    raise SystemExit(0)
fresh.sort(key=lambda w: w.get("id") or 0)
print(fresh[-1]["id"])
' "$before")
    if [[ -n "$id" ]]; then
      niri msg action move-window-to-monitor --id "$id" "$output" || true
      exit 0
    fi
    sleep 0.05
  done
) &

flameshot gui
