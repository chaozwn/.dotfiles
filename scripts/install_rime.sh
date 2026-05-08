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

ensure_fcitx5_behavior_option() {
  local cfg="$1"
  local key="$2"
  local value="$3"

  if grep -q "^${key}=${value}$" "$cfg"; then
    echo "✅ fcitx5 ${key}=${value} already set"
    return 0
  fi

  if grep -q "^${key}=" "$cfg"; then
    sed -i.bak "s/^${key}=.*/${key}=${value}/" "$cfg"
    echo "✅ fcitx5 ${key} set to ${value} (backup at ${cfg}.bak)"
  elif grep -q '^\[Behavior\]' "$cfg"; then
    sed -i.bak "/^\[Behavior\]/a ${key}=${value}" "$cfg"
    echo "✅ fcitx5 ${key}=${value} added under [Behavior] (backup at ${cfg}.bak)"
  else
    printf '\n[Behavior]\n%s=%s\n' "$key" "$value" >> "$cfg"
    echo "✅ fcitx5 [Behavior]/${key}=${value} appended"
  fi
}

# Per-app vmode (and rime app_options in general) works best with isolated
# input contexts. Idempotently enforce the two behavior flags we maintain in
# fcitx5/config so fresh machines converge even before dotbot links the file.
configure_fcitx5_behavior() {
  local cfg="$HOME/.config/fcitx5/config"

  if [ ! -f "$cfg" ]; then
    echo "ℹ️  $cfg not found yet (run fcitx5 once); skipping fcitx5 behavior options"
    return 0
  fi

  ensure_fcitx5_behavior_option "$cfg" "resetStateWhenFocusIn" "No"
  ensure_fcitx5_behavior_option "$cfg" "ShareInputState" "No"
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
    configure_fcitx5_behavior
  fi
}

main "$@"
