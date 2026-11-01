#!/usr/bin/env bash
# Pick one monitor, then open Flameshot on that monitor only.
# slurp -o -r draws a box on each output; click the screen to capture.
set -euo pipefail

output=$(slurp -o -r -f '%o' </dev/null | tr -d '\n') || exit 0
if [[ -z "$output" || "$output" == "<unknown>" ]]; then
  exit 0
fi

request="${XDG_RUNTIME_DIR:-/tmp}/flameshot-output"
printf '%s\n' "$output" >"$request"
exec flameshot gui
