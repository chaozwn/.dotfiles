#!/usr/bin/env bash
# Pin the latest screenshot as a Flameshot floating card.
# Prefers an image on the clipboard, then a path copied as text, then the
# newest file in ~/Screenshots.
set -euo pipefail

shot_dir="${HOME}/Screenshots"
tmp=$(mktemp --suffix=.png)
trap 'rm -f "$tmp"' EXIT

if wl-paste --type image/png >"$tmp" 2>/dev/null && [[ -s "$tmp" ]]; then
  :
else
  : >"$tmp"
  text=$(wl-paste --type text/plain 2>/dev/null || true)
  if [[ -n "$text" && -f "$text" ]]; then
    cp -- "$text" "$tmp"
  elif [[ -d "$shot_dir" ]]; then
    newest=$(find "$shot_dir" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)
    if [[ -n "${newest:-}" && -f "$newest" ]]; then
      cp -- "$newest" "$tmp"
    fi
  fi
fi

if [[ ! -s "$tmp" ]]; then
  notify-send -a Flameshot "没有可钉住的截图" "先用 F1 截一张，或把图片复制到剪贴板。" 2>/dev/null || true
  exit 1
fi

# attachPin expects a Qt QDataStream of QPixmap + QRect, not a raw PNG.
png="$tmp"
if ! magick identify -format '%m' "$tmp" 2>/dev/null | grep -qx PNG; then
  png="${tmp}.norm.png"
  magick "$tmp" "png32:$png"
  trap 'rm -f "$tmp" "$png"' EXIT
fi

/usr/bin/python3 - "$png" <<'PY'
import struct
import sys
from gi.repository import Gio, GLib

data = open(sys.argv[1], "rb").read()
if len(data) < 24 or data[:8] != b"\x89PNG\r\n\x1a\n":
    raise SystemExit(1)

width, height = struct.unpack(">II", data[16:24])
x, y = 80, 80
# QRect is stored as left, top, right, bottom. QDataStream uses big-endian.
payload = struct.pack(">i", 1) + data + struct.pack(
    ">iiii", x, y, x + width - 1, y + height - 1
)

bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
bus.call_sync(
    "org.flameshot.Flameshot",
    "/",
    "org.flameshot.Flameshot",
    "attachPin",
    GLib.Variant("(ay)", (payload,)),
    None,
    Gio.DBusCallFlags.NONE,
    5000,
    None,
)
PY
