#!/usr/bin/env bash

# Ensure the Rime user dir exists by cloning iDvel/rime-ice on first run.
# Custom *.custom.yaml / lua files in ../rime/ are layered on top via dotbot
# (see install.conf.yaml).

set -e

RIME_REPO="https://github.com/iDvel/rime-ice.git"

get_rime_user_dir() {
  case "$(uname)" in
    Darwin)
      echo "$HOME/Library/Rime"
      ;;
    Linux)
      if [ -d "$HOME/.config/ibus" ] && [ ! -d "$HOME/.config/fcitx5" ]; then
        echo "$HOME/.config/ibus/rime"
      else
        echo "$HOME/.local/share/fcitx5/rime"
      fi
      ;;
    *)
      echo ""
      ;;
  esac
}

clone_rime_ice() {
  local target="$1"

  if [ -d "$target/.git" ]; then
    echo "✅ Rime user dir already a git repo: $target"
    return 0
  fi

  if [ -d "$target" ] && [ -n "$(ls -A "$target" 2>/dev/null)" ]; then
    echo "⚠️  $target exists and is non-empty but not a git repo."
    echo "    Skipping clone to avoid clobbering. Move/back it up and re-run if you want rime-ice."
    return 0
  fi

  mkdir -p "$(dirname "$target")"
  echo "==> Cloning rime-ice into $target ..."
  git clone --depth=1 "$RIME_REPO" "$target"
  echo "✅ rime-ice ready at $target"
}

# Per-app vmode (and rime app_options in general) only re-applies on focus
# change when fcitx5's "Share Input State" is set to No. Idempotently enforce
# that here so app_options/vmode just works on a fresh machine.
configure_fcitx5_share_input_state() {
  local cfg="$HOME/.config/fcitx5/config"

  if [ ! -f "$cfg" ]; then
    echo "ℹ️  $cfg not found yet (run fcitx5 once); skipping ShareInputState"
    return 0
  fi

  if grep -q '^ShareInputState=No$' "$cfg"; then
    echo "✅ fcitx5 ShareInputState=No already set"
    return 0
  fi

  if grep -q '^ShareInputState=' "$cfg"; then
    sed -i.bak 's/^ShareInputState=.*/ShareInputState=No/' "$cfg"
    echo "✅ fcitx5 ShareInputState set to No (backup at ${cfg}.bak)"
  elif grep -q '^\[Behavior\]' "$cfg"; then
    sed -i.bak '/^\[Behavior\]/a ShareInputState=No' "$cfg"
    echo "✅ fcitx5 ShareInputState=No added under [Behavior] (backup at ${cfg}.bak)"
  else
    printf '\n[Behavior]\nShareInputState=No\n' >> "$cfg"
    echo "✅ fcitx5 [Behavior]/ShareInputState=No appended"
  fi
}

main() {
  local target
  target="$(get_rime_user_dir)"

  if [ -z "$target" ]; then
    echo "ℹ️  Skipping rime: unsupported OS $(uname)"
    return 0
  fi

  clone_rime_ice "$target"

  if [ "$(uname)" = "Linux" ]; then
    configure_fcitx5_share_input_state
  fi
}

main "$@"
