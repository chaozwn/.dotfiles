#!/usr/bin/env bash
# Alt+J/K: move between workspaces, and continue onto the monitor
# below or above when this monitor has no workspace left in that direction.
set -euo pipefail

direction=${1:-}
if [[ "$direction" != "down" && "$direction" != "up" ]]; then
  echo "usage: $0 down|up" >&2
  exit 1
fi

/usr/bin/python3 - "$direction" <<'PY'
import json
import subprocess
import sys

direction = sys.argv[1]


def niri_json(*args):
    raw = subprocess.check_output(["niri", "msg", "--json", *args])
    return json.loads(raw)


def action(*args):
    subprocess.check_call(["niri", "msg", "action", *args])


workspaces = niri_json("workspaces")
focused = next(ws for ws in workspaces if ws.get("is_focused"))
same = [ws for ws in workspaces if ws.get("output") == focused.get("output")]

# Niri keeps an empty workspace at the bottom of every monitor. Skip that
# tail when the move crosses to another monitor.
last_idx = max(ws["idx"] for ws in same)

if direction == "down":
    if any(ws["idx"] > focused["idx"] and ws["idx"] < last_idx for ws in same):
        action("focus-workspace-down")
        raise SystemExit(0)
    before = focused["output"]
    action("focus-monitor-down")
    landed = next(ws for ws in niri_json("workspaces") if ws.get("is_focused"))
    if landed.get("output") != before:
        action("focus-workspace", "1")
else:
    if any(ws["idx"] < focused["idx"] for ws in same):
        action("focus-workspace-up")
        raise SystemExit(0)
    before = focused["output"]
    action("focus-monitor-up")
    current = niri_json("workspaces")
    landed = next(ws for ws in current if ws.get("is_focused"))
    if landed.get("output") != before:
        group = [ws for ws in current if ws.get("output") == landed.get("output")]
        tail = max(ws["idx"] for ws in group)
        action("focus-workspace", str(tail - 1 if tail > 1 else tail))
PY
