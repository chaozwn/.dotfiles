#!/usr/bin/env bash
# Cross-platform clipboard pipe for tmux copy-mode.
# stdin -> system clipboard (macOS / Wayland / X11).

set -u

if command -v pbcopy >/dev/null 2>&1; then
  exec pbcopy
fi

if [ -n "${WAYLAND_DISPLAY:-}" ] && command -v wl-copy >/dev/null 2>&1; then
  exec wl-copy
fi

if [ -n "${DISPLAY:-}" ]; then
  if command -v xclip >/dev/null 2>&1; then
    exec xclip -selection clipboard -in
  fi
  if command -v xsel >/dev/null 2>&1; then
    exec xsel --clipboard --input
  fi
fi

if command -v wl-copy >/dev/null 2>&1; then
  exec wl-copy
fi

cat >/dev/null
exit 0
