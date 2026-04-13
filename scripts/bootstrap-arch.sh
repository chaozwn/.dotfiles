#!/usr/bin/env bash
# Native Arch Linux bootstrap (no Homebrew). Keeps the same toolchain as brew-both.txt where possible.
# Optional: tmuxinator — gem install tmuxinator (needs ruby)
# Optional: bob (Neovim version manager) — paru/yay: bob-bin, or install from upstream
# Optional: nvm — install via https://github.com/nvm-sh/nvm or use fnm from AUR

set -euo pipefail

echo "==> Installing packages via pacman (official repos)..."

sudo pacman -S --needed \
  base-devel git curl \
  fish starship fastfetch bat fd grc htop mosh tmux eza ncdu bottom \
  file yazi ffmpegthumbnailer jq poppler ripgrep fzf zoxide \
  perl-image-exiftool lazygit lazydocker \
  p7zip imagemagick ripgrep-all mediainfo glow gdu protobuf ast-grep chafa git-delta \
  coreutils neovim numbat gum github-cli \
  ttf-jetbrains-mono-nerd

echo ""
echo "✅ Pacman packages installed."
echo "ℹ️  Not in official repos: tmuxinator (gem), unar (AUR), nvm (script/AUR), bob (AUR)."
echo "ℹ️  Match Mac workflow: clone this repo to ~/.dotfiles and run bash install for dotbot symlinks."
