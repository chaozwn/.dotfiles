#!/usr/bin/env bash
# Native Fedora bootstrap (no Homebrew). Keeps the same toolchain as brew-both.txt where possible.
# Optional: tmuxinator — gem install tmuxinator (needs ruby)
# Optional: bob, nvm — install upstream (see brew-both.txt)
#
# Extras not in Fedora base+updates (fc43): starship, bottom, lazygit, yazi — install with:
#   DOTFILES_FEDORA_COPR=1 bash scripts/bootstap-fedora.sh

set -euo pipefail

echo "==> Installing packages via dnf (Fedora official repositories)..."

sudo dnf install -y \
  @development-tools \
  git curl \
  fish fastfetch bat fd-find grc htop mosh tmux eza ncdu \
  file ffmpegthumbnailer jq poppler-utils ripgrep fzf zoxide \
  perl-Image-ExifTool \
  7zip 7zip-standalone \
  ImageMagick unar mediainfo glow gdu protobuf-compiler chafa git-delta \
  coreutils neovim gum gh \
  jetbrains-mono-fonts

if [ "${DOTFILES_FEDORA_COPR:-0}" = "1" ]; then
  echo "==> Enabling COPR (starship, bottom, lazygit, yazi)..."
  sudo dnf copr enable -y atim/starship
  sudo dnf copr enable -y atim/bottom
  sudo dnf copr enable -y dejan/lazygit
  sudo dnf copr enable -y lihaohong/yazi
  sudo dnf install -y starship bottom lazygit yazi
fi

echo ""
echo "✅ dnf packages installed."
if [ "${DOTFILES_FEDORA_COPR:-0}" != "1" ]; then
  echo "ℹ️  Missing from Fedora base repos: starship, bottom, lazygit, yazi — re-run with DOTFILES_FEDORA_COPR=1 or install manually."
fi
echo "ℹ️  GitHub CLI \`gh\` is installed; classic \`hub\` is optional if you still need it."
echo "ℹ️  Not covered here: ripgrep-all, ast-grep, numbat, lazydocker, nvm, bob (install from upstream/COPR/cargo)."
echo "ℹ️  Fonts: jetbrains-mono-fonts is installed; for Nerd-patched glyphs use ~/.dotfiles/fonts/*.ttf (see install_fonts.sh)."
echo "ℹ️  Match Mac workflow: clone this repo to ~/.dotfiles and run bash install for dotbot symlinks."
