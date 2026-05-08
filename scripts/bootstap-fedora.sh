#!/usr/bin/env bash
# Native Fedora bootstrap (no Homebrew). Keeps the same toolchain as brew-both.txt where possible.
# Optional: tmuxinator — gem install tmuxinator (needs ruby)
# Optional: nvm — install upstream (see brew-both.txt)
# Optional: bob (Neovim version manager) — official script, no Homebrew:
#   DOTFILES_BOB=0 bash scripts/bootstap-fedora.sh   # skip bob (default: install)
#
# Extras not in Fedora base+updates (fc43): starship, bottom, lazygit, yazi — installed via COPR by default.
#   DOTFILES_FEDORA_COPR=0 bash scripts/bootstap-fedora.sh   # skip third-party COPR repos

set -euo pipefail

install_lazydocker() {
  if command -v lazydocker &>/dev/null; then
    return
  fi

  echo "==> Installing lazydocker to ~/.local/bin from upstream..."
  mkdir -p "$HOME/.local/bin"
  if ! curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | DIR="$HOME/.local/bin" bash; then
    echo "⚠️  lazydocker install failed; install manually if you use the Yazi td binding."
  fi
}

echo "==> Installing packages via dnf (Fedora official repositories)..."

sudo dnf install -y \
  @development-tools \
  git curl \
  fish fastfetch bat fd-find grc htop mosh tmux eza ncdu \
  file ffmpegthumbnailer jq poppler-utils ripgrep fzf zoxide mpv resvg \
  perl-Image-ExifTool \
  7zip 7zip-standalone \
  ImageMagick libgomp unar mediainfo glow gdu protobuf-compiler chafa git-delta \
  coreutils neovim gum gh \
  jetbrains-mono-fonts 

if [ "${DOTFILES_FEDORA_COPR:-1}" = "1" ]; then
  echo "==> Enabling COPR (starship, bottom, lazygit, yazi)..."
  sudo dnf copr enable -y atim/starship
  sudo dnf copr enable -y atim/bottom
  sudo dnf copr enable -y dejan/lazygit
  sudo dnf copr enable -y lihaohong/yazi
  sudo dnf install -y starship bottom lazygit yazi
fi

install_lazydocker

if [ "${DOTFILES_BOB:-1}" = "1" ]; then
  echo "==> Installing bob (Neovim version manager) to ~/.local/bin..."
  mkdir -p ~/.local/bin
  curl -fsSL https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh | bash
fi

echo ""
echo "✅ dnf packages installed."
if [ "${DOTFILES_FEDORA_COPR:-1}" != "1" ]; then
  echo "ℹ️  COPR skipped (DOTFILES_FEDORA_COPR=0): starship, bottom, lazygit, yazi were not installed — run again with default (COPR on) or install manually."
fi
echo "ℹ️  GitHub CLI \`gh\` is installed (e.g. \`gh pr checkout\` for PR branches)."
if [ "${DOTFILES_BOB:-1}" != "1" ]; then
  echo "ℹ️  Bob skipped (DOTFILES_BOB=0): install with \`curl -fsSL https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh | bash\`"
fi
if ! command -v ya &>/dev/null; then
  echo "ℹ️  ya: missing. Ensure your Yazi package includes both \`yazi\` and \`ya\` if you use \`ya pack\`."
fi
echo "ℹ️  Not covered here: ripgrep-all, ast-grep, numbat, nvm (install from upstream)."
echo "ℹ️  Fonts: jetbrains-mono-fonts is installed; for Nerd-patched glyphs use ~/.dotfiles/fonts/*.ttf (see install_fonts.sh)."
echo "ℹ️  Match Mac workflow: clone this repo to ~/.dotfiles and run bash install for dotbot symlinks."
