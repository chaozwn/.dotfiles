#!/usr/bin/env bash
# Pick one monitor and open Flameshot on that image.
#
# Flameshot 13 lays the toolbar out using Qt screen rectangles. These outputs
# do not start at (0, 0), and the laptop panel is 1.75x, so on that screen the
# buttons land past the right edge and only Pin stays visible. While the editor
# is open, put the chosen output at (0, 0) and park the others. Positions are
# restored when the editor closes, and also if a previous run was interrupted.
set -euo pipefail

snapshot="${XDG_RUNTIME_DIR:-/tmp}/flameshot-output-layout"

restore_file() {
  local file=$1
  local name x y
  [[ -f "$file" ]] || return 0
  while IFS=$'\t' read -r name x y; do
    [[ -n "$name" ]] || continue
    niri msg output "$name" position set "$x" "$y" >/dev/null 2>&1 || true
  done <"$file"
}

# A crashed editor can leave the outputs parked. Put them back first.
if [[ -f "$snapshot" ]]; then
  restore_file "$snapshot"
  rm -f "$snapshot"
fi

output=$(slurp -o -r -f '%o' </dev/null | tr -d '\n') || exit 0
if [[ -z "$output" || "$output" == "<unknown>" ]]; then
  exit 0
fi

layout=$(niri msg --json outputs | /usr/bin/python3 -c '
import json, sys
chosen = sys.argv[1]
outputs = json.load(sys.stdin)
if chosen not in outputs:
    raise SystemExit(1)
logical = outputs[chosen]["logical"]
print("%d %d" % (int(logical["width"]), int(logical["height"])))
for name, info in outputs.items():
    pos = info["logical"]
    print("%s\t%d\t%d" % (name, int(pos["x"]), int(pos["y"])))
' "$output")

read -r width height <<<"${layout%%$'\n'*}"
saved=${layout#*$'\n'}
printf '%s\n' "$saved" >"$snapshot"

restore_layout() {
  restore_file "$snapshot"
  rm -f "$snapshot"
}
trap restore_layout EXIT

niri msg output "$output" position set 0 0 >/dev/null
offset=8000
while IFS=$'\t' read -r name x y; do
  [[ -n "$name" && "$name" != "$output" ]] || continue
  niri msg output "$name" position set "$offset" 0 >/dev/null
  offset=$((offset + 4000))
done <<<"$saved"

# Qt reads output positions when the editor is created.
sleep 0.3
pkill -x flameshot >/dev/null 2>&1 || true
sleep 0.15

request="${XDG_RUNTIME_DIR:-/tmp}/flameshot-output"
printf '%s\n' "$output" >"$request"
niri msg action focus-monitor "$output" >/dev/null || true

before=$(niri msg --json windows | /usr/bin/python3 -c '
import json, sys
windows = json.load(sys.stdin)
print(" ".join(str(w["id"]) for w in windows if w.get("app_id") == "flameshot"))
')

flameshot gui >/dev/null 2>&1 &
gui_pid=$!

editor_id=""
for _ in $(seq 1 60); do
  editor_id=$(niri msg --json windows | /usr/bin/python3 -c '
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
  if [[ -n "$editor_id" ]]; then
    break
  fi
  sleep 0.05
done

if [[ -n "$editor_id" ]]; then
  niri msg action focus-window --id "$editor_id" >/dev/null || true
  niri msg action move-window-to-monitor --id "$editor_id" "$output" >/dev/null || true
  niri msg action move-floating-window --id "$editor_id" -x 0 -y 0 >/dev/null || true
  niri msg action set-window-width --id "$editor_id" "$width" >/dev/null || true
  niri msg action set-window-height --id "$editor_id" "$height" >/dev/null || true
  while niri msg --json windows | /usr/bin/python3 -c '
import json, sys
target = sys.argv[1]
windows = json.load(sys.stdin)
raise SystemExit(0 if any(str(w.get("id")) == target for w in windows) else 1)
' "$editor_id"; do
    sleep 0.3
  done
fi

wait "$gui_pid" 2>/dev/null || true
