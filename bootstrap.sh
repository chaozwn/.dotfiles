#!/usr/bin/env bash
set -e

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$BASEDIR"

USE_BREW=1
if [ "${DOTFILES_USE_BREW:-0}" != "1" ]; then
  if [ -f /etc/arch-release ] || [ -f /etc/fedora-release ]; then
    USE_BREW=0
  fi
fi

# ── Steps 1–2: package manager ───────────────────────────────────
if [ "$USE_BREW" = "1" ]; then
  echo "==> [1/7] Installing Homebrew..."
  bash "$BASEDIR/brew/0.install.sh"
  echo "==> [2/7] Installing brew packages..."
  bash "$BASEDIR/brew/1.brewInstallApps.sh"
else
  if [ -f /etc/arch-release ]; then
    echo "==> [1-2/7] Arch Linux: installing packages via pacman (set DOTFILES_USE_BREW=1 to use Homebrew on Linux)..."
    bash "$BASEDIR/scripts/bootstrap-arch.sh"
  elif [ -f /etc/fedora-release ]; then
    echo "==> [1-2/7] Fedora: installing packages via dnf (set DOTFILES_USE_BREW=1 to use Homebrew on Linux)..."
    bash "$BASEDIR/scripts/bootstap-fedora.sh"
  else
    echo "Unsupported distro for native package bootstrap. Use DOTFILES_USE_BREW=1 or install packages manually."
    exit 1
  fi
fi

# ── Step 3: Fish shell ──────────────────────────────────────────
echo "==> [3/7] Setting fish as default shell..."
FISH_PATH=""
for candidate in /opt/homebrew/bin/fish /home/linuxbrew/.linuxbrew/bin/fish /usr/bin/fish; do
  if [ -x "$candidate" ]; then
    FISH_PATH="$candidate"
    break
  fi
done

if [ -n "$FISH_PATH" ]; then
  if ! grep -qF "$FISH_PATH" /etc/shells 2>/dev/null; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells
  fi
  LOGIN_SHELL="$(getent passwd "$(id -un)" | cut -d: -f7)"
  if [ "$LOGIN_SHELL" != "$FISH_PATH" ]; then
    if ! chsh -s "$FISH_PATH" 2>/dev/null; then
      echo "⚠️  chsh failed (wrong password, or shell not allowed). Try:"
      echo "    chsh -s $FISH_PATH"
      echo "    # if needed: echo $FISH_PATH | sudo tee -a /etc/shells"
    fi
  fi
  LOGIN_SHELL="$(getent passwd "$(id -un)" | cut -d: -f7)"
  if [ "$LOGIN_SHELL" = "$FISH_PATH" ]; then
    echo "✅ Login shell is $FISH_PATH"
  else
    echo "⚠️  Login shell is still $LOGIN_SHELL (wanted $FISH_PATH). Run: chsh -s $FISH_PATH"
  fi
else
  echo "⚠️  fish not found in common locations, skipping shell change (install fish first)"
fi

# ── Step 4: Fonts ────────────────────────────────────────────────
echo "==> [4/7] Installing fonts..."
bash "$BASEDIR/scripts/install_fonts.sh"

# ── Step 5: Dotbot symlinks ─────────────────────────────────────
echo "==> [5/7] Linking dotfiles via dotbot..."
bash "$BASEDIR/install"

# ── Step 6: Miniconda ───────────────────────────────────────────
if [ "${DOTFILES_SKIP_MINICONDA:-0}" != "1" ]; then
  echo "==> [6/7] Installing Miniconda..."
  bash "$BASEDIR/scripts/install_miniconda.sh"
else
  echo "==> [6/7] Skipping Miniconda (DOTFILES_SKIP_MINICONDA=1)"
fi

# ── Step 7: Node.js ─────────────────────────────────────────────
echo "==> [7/7] Installing Node.js via nvm..."
if command -v fish &>/dev/null; then
  fish "$BASEDIR/nvm/install_node.sh"
else
  echo "⚠️  fish not available, skipping Node.js install (run nvm/install_node.sh manually in fish)"
fi

echo ""
echo "🎉 All done! Restart your terminal to use fish."
