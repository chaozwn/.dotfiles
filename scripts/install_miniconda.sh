#!/usr/bin/env bash
# Install Miniconda to ~/miniconda3 (matches fish/config.fish).
# Idempotent: skips if $PREFIX/bin/conda already exists.
# Optional: MINICONDA_PREFIX=... DOTFILES_SKIP_MINICONDA=1 (handled by caller)

set -euo pipefail

PREFIX="${MINICONDA_PREFIX:-$HOME/miniconda3}"

if [[ -x "$PREFIX/bin/conda" ]]; then
  echo "Miniconda already present at $PREFIX, skipping."
  exit 0
fi

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Linux)
    case "$ARCH" in
      x86_64) INSTALLER="Miniconda3-latest-Linux-x86_64.sh" ;;
      aarch64) INSTALLER="Miniconda3-latest-Linux-aarch64.sh" ;;
      *)
        echo "Unsupported Linux architecture: $ARCH" >&2
        exit 1
        ;;
    esac
    ;;
  Darwin)
    case "$ARCH" in
      arm64) INSTALLER="Miniconda3-latest-MacOSX-arm64.sh" ;;
      x86_64) INSTALLER="Miniconda3-latest-MacOSX-x86_64.sh" ;;
      *)
        echo "Unsupported macOS architecture: $ARCH" >&2
        exit 1
        ;;
    esac
    ;;
  *)
    echo "Unsupported operating system: $OS" >&2
    exit 1
    ;;
esac

URL="https://repo.anaconda.com/miniconda/$INSTALLER"
# Installer requires a .sh filename (not "bash /tmp/abc" without suffix).
TMP="$(mktemp "${TMPDIR:-/tmp}/miniconda-install.XXXXXX.sh")"
trap 'rm -f "$TMP"' EXIT

echo "Downloading $INSTALLER ..."
curl -fsSL "$URL" -o "$TMP"
echo "Installing to $PREFIX ..."
bash "$TMP" -b -p "$PREFIX"
echo "Miniconda installed at $PREFIX."
