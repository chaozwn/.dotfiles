#!/usr/bin/env bash
set -e

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$BASEDIR"

# ── Step 1: Homebrew ─────────────────────────────────────────────
echo "==> [1/6] Installing Homebrew..."
bash "$BASEDIR/brew/0.install.sh"

# ── Step 2: Brew packages ───────────────────────────────────────
echo "==> [2/6] Installing brew packages..."
bash "$BASEDIR/brew/1.brewInstallApps.sh"

# ── Step 3: Fish shell ──────────────────────────────────────────
echo "==> [3/6] Setting fish as default shell..."
if [ "$(uname)" = "Darwin" ]; then
  FISH_PATH="/opt/homebrew/bin/fish"
else
  FISH_PATH="/home/linuxbrew/.linuxbrew/bin/fish"
fi

if [ -x "$FISH_PATH" ]; then
  if ! grep -qF "$FISH_PATH" /etc/shells 2>/dev/null; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells
  fi
  if [ "$SHELL" != "$FISH_PATH" ]; then
    chsh -s "$FISH_PATH"
  fi
  echo "✅ fish is set as default shell"
else
  echo "⚠️  fish not found at $FISH_PATH, skipping shell change"
fi

# ── Step 4: Fonts ────────────────────────────────────────────────
echo "==> [4/6] Installing fonts..."
bash "$BASEDIR/scripts/install_kitty.sh"

# ── Step 5: Dotbot symlinks ─────────────────────────────────────
echo "==> [5/6] Linking dotfiles via dotbot..."
bash "$BASEDIR/install"

# ── Step 6: Node.js ─────────────────────────────────────────────
echo "==> [6/6] Installing Node.js via nvm..."
if command -v fish &>/dev/null; then
  fish "$BASEDIR/nvm/install_node.sh"
else
  echo "⚠️  fish not available, skipping Node.js install (run nvm/install_node.sh manually in fish)"
fi

echo ""
echo "🎉 All done! Restart your terminal to use fish."
