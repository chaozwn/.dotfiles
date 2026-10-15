#!/usr/bin/env bash
# Reload the fcitx5 classic UI after Noctalia rewrites the candidate theme.
set -euo pipefail

if ! command -v dbus-send >/dev/null 2>&1; then
  exit 0
fi

if ! dbus-send --print-reply=literal --dest=org.fcitx.Fcitx5 \
  /controller org.fcitx.Fcitx.Controller1.State >/dev/null 2>&1; then
  exit 0
fi

dbus-send --type=method_call --dest=org.fcitx.Fcitx5 \
  /controller org.fcitx.Fcitx.Controller1.ReloadAddonConfig \
  string:classicui
