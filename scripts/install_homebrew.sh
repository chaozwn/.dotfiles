#!/usr/bin/env bash

set -euo pipefail

HOMEBREW_PATH="/opt/homebrew"

if [[ -d "$HOMEBREW_PATH" ]]; then
  echo "Homebrew is already installed"
  exit 0
fi

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
