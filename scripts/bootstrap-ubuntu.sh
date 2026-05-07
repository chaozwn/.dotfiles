#!/usr/bin/env bash
# Native Ubuntu bootstrap (no Homebrew). Same roles as brew-both + scripts/bootstap-fedora.sh where possible.
# Optional: tmuxinator — gem install tmuxinator
# Optional: nvm — installed later by bootstrap.sh via nvm.fish
# Optional: bob (Neovim version manager) —
#   DOTFILES_BOB=0 bash scripts/bootstrap-ubuntu.sh   # skip bob (default: install)
#
# Extras not always in your release (e.g. lazydocker, ast-grep): install from upstream; see end-of-run hints.
# Enable universe if needed: sudo add-apt-repository universe

set -euo pipefail

echo "==> Installing packages via apt (Ubuntu official repositories + universe where needed)..."

sudo apt-get update

# Core: avoid one huge failure if a single name differs — split required vs optional.
REQUIRED_PKGS=(
  build-essential
  git curl wget ca-certificates
  fish starship fastfetch bat fd-find grc htop mosh tmux eza ncdu
  file ffmpegthumbnailer jq poppler-utils ripgrep fzf zoxide
  libimage-exiftool-perl
  p7zip-full
  imagemagick unar mediainfo
  chafa gdu glow protobuf-compiler
  coreutils
  neovim gum gh
  git-delta
  numbat ripgrep-all
  lazygit
  fonts-jetbrains-mono
)

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${REQUIRED_PKGS[@]}"

# bottom: present on many recent Ubuntu (universe); skip gracefully on older systems.
# yazi: installed via snap (https://snapcraft.io/yazi), not apt — snap tracks upstream better.
OPTPKGS=()
if apt-cache show bottom &>/dev/null; then OPTPKGS+=("bottom"); fi
if ((${#OPTPKGS[@]} > 0)); then
  echo "==> Optional packages from apt: ${OPTPKGS[*]}"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${OPTPKGS[@]}"
else
  echo "ℹ️  No \`bottom\` in apt cache — install manually (see hints below) or use a backports/PPA."
fi

if ! command -v snap &>/dev/null; then
  echo "==> Installing snapd (required for yazi)..."
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends snapd
fi
echo "==> Installing yazi via snap (classic confinement)..."
sudo snap install yazi --classic

# fd (Debian): binary is fdfind; make \`fd\` available for configs that call \`fd\`.
if command -v fdfind &>/dev/null; then
  if ! command -v fd &>/dev/null; then
    if [ -d /usr/lib/cargo/bin ] && [ -x /usr/lib/cargo/bin/fd ]; then
      : # some installs expose fd here
    else
      sudo update-alternatives --install /usr/bin/fd fd /usr/bin/fdfind 10 2>/dev/null || true
    fi
  fi
fi

if [ "${DOTFILES_BOB:-1}" = "1" ]; then
  echo "==> Installing bob (Neovim version manager) to ~/.local/bin..."
  mkdir -p ~/.local/bin
  curl -fsSL https://raw.githubusercontent.com/MordechaiHadad/bob/master/scripts/install.sh | bash
fi

echo ""
echo "✅ apt packages (and yazi from snap) installed."
if ! command -v btm &>/dev/null; then
  echo "ℹ️  bottom: if missing, see https://github.com/ClementTsang/bottom/releases (or a PPA with bottom)."
fi
if ! command -v yazi &>/dev/null; then
  echo "ℹ️  yazi: if missing, run: sudo snap install yazi --classic (see https://snapcraft.io/yazi)."
fi
echo "ℹ️  GitHub CLI \`gh\` is installed (e.g. \`gh pr checkout\`)."
if [ "${DOTFILES_BOB:-1}" != "1" ]; then
  echo "ℹ️  Bob skipped (DOTFILES_BOB=0): install with the bob upstream install script if needed."
fi
echo "ℹ️  Not always in default repos: lazydocker, ast-grep, nvm (bootstrap installs nvm in a later step), tmuxinator (gem)."
echo "ℹ️  fonts-jetbrains-mono is a base JetBrains set; for Nerd-patched icons copy ~/.dotfiles/fonts/*.ttf (see install_fonts.sh)."
echo "ℹ️  Match Mac workflow: clone this repo to ~/.dotfiles and run \`bash install\` for dotbot symlinks."
