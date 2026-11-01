#!/usr/bin/env bash
# Keep one watcher that turns a just-saved Flameshot copy into a text path.
set -euo pipefail

lock="${XDG_RUNTIME_DIR:-/tmp}/flameshot-clipboard-bridge.lock"
exec 9>"$lock"
flock -n 9 || exit 0

# Do not exec: this process must keep the lock for the whole session.
wl-paste --type image/png --watch "$HOME/.dotfiles/scripts/flameshot-clipboard-to-path.sh"
