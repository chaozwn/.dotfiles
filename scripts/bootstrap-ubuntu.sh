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

install_yazi() {
  local target version tmp url

  case "$(uname -m)" in
    x86_64|amd64) target="x86_64-unknown-linux-gnu" ;;
    aarch64|arm64) target="aarch64-unknown-linux-gnu" ;;
    *) target="" ;;
  esac

  if [ -n "$target" ]; then
    echo "==> Installing yazi + ya from the official GitHub .deb..."
    version="$(curl -fsSL https://api.github.com/repos/sxyazi/yazi/releases/latest | jq -r '.tag_name' 2>/dev/null || true)"
    if [ -n "$version" ] && [ "$version" != "null" ]; then
      tmp="$(mktemp -d)"
      url="https://github.com/sxyazi/yazi/releases/download/${version}/yazi-${target}.deb"
      if curl -fL "$url" -o "$tmp/yazi.deb"; then
        if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$tmp/yazi.deb"; then
          rm -rf "$tmp"
          return 0
        fi
      fi
      rm -rf "$tmp"
    fi
  fi

  echo "⚠️  Official .deb install failed or is unsupported; falling back to snap."
  if ! command -v snap &>/dev/null; then
    echo "==> Installing snapd (required for yazi fallback)..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends snapd
  fi
  if snap list yazi &>/dev/null; then
    sudo snap refresh yazi --classic
  else
    sudo snap install yazi --classic
  fi
}

install_bat_command() {
  if ! command -v bat &>/dev/null && command -v batcat &>/dev/null; then
    echo "==> Exposing Debian/Ubuntu batcat as bat for Yazi/fzf previews..."
    sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
  fi
}

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

# Core: avoid one huge failure if a single name differs — split required vs optional.
REQUIRED_PKGS=(
  build-essential
  git curl wget ca-certificates
  fish starship fastfetch bat fd-find grc htop mosh tmux eza ncdu
  file ffmpegthumbnailer jq poppler-utils ripgrep fzf zoxide
  libimage-exiftool-perl
  p7zip-full
  imagemagick libgomp1 unar mediainfo mpv
  chafa gdu glow protobuf-compiler
  coreutils
  neovim gum gh
  git-delta
  numbat ripgrep-all
  lazygit
  fonts-jetbrains-mono
)

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${REQUIRED_PKGS[@]}"

# Some packages are present on many recent Ubuntu releases; skip gracefully on older systems.
OPTPKGS=()
if apt-cache show bottom &>/dev/null; then OPTPKGS+=("bottom"); fi
if apt-cache show resvg &>/dev/null; then OPTPKGS+=("resvg"); fi
if ((${#OPTPKGS[@]} > 0)); then
  echo "==> Optional packages from apt: ${OPTPKGS[*]}"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${OPTPKGS[@]}"
else
  echo "ℹ️  No optional Yazi/helper packages in apt cache — install manually (see hints below) or use a backports/PPA."
fi

install_yazi
install_bat_command
install_lazydocker

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
echo "✅ apt packages and Yazi tooling installed."
if ! command -v btm &>/dev/null; then
  echo "ℹ️  bottom: if missing, see https://github.com/ClementTsang/bottom/releases (or a PPA with bottom)."
fi
if ! command -v yazi &>/dev/null; then
  echo "ℹ️  yazi: if missing, install from https://github.com/sxyazi/yazi/releases or run: sudo snap install yazi --classic."
fi
if ! command -v ya &>/dev/null; then
  echo "ℹ️  ya: missing. Prefer the official Yazi .deb over snap if you want \`ya pack\` plugin management."
fi
if ! command -v bat &>/dev/null; then
  echo "ℹ️  bat: missing. On Ubuntu this may be installed as \`batcat\`; create a \`bat\` shim for Yazi/fzf previews."
fi
if ! command -v mpv &>/dev/null; then
  echo "ℹ️  mpv: missing; audio/video open rules in yazi.toml will not work."
fi
if ! command -v resvg &>/dev/null; then
  echo "ℹ️  resvg: optional SVG preview helper is missing."
fi
echo "ℹ️  GitHub CLI \`gh\` is installed (e.g. \`gh pr checkout\`)."
if [ "${DOTFILES_BOB:-1}" != "1" ]; then
  echo "ℹ️  Bob skipped (DOTFILES_BOB=0): install with the bob upstream install script if needed."
fi
echo "ℹ️  Not always in default repos: ast-grep, nvm (bootstrap installs nvm in a later step), tmuxinator (gem), ueberzugpp."
echo "ℹ️  fonts-jetbrains-mono is a base JetBrains set; for Nerd-patched icons copy ~/.dotfiles/fonts/*.ttf (see install_fonts.sh)."
echo "ℹ️  Match Mac workflow: clone this repo to ~/.dotfiles and run \`bash install\` for dotbot symlinks."
