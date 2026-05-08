#!/bin/bash

# Install JetBrains Nerd Font for terminals (Ghostty, Kitty, etc.) via fontconfig on Linux,
# or Homebrew cask on macOS.

get_system_info() {
  OS_TYPE="$(uname)"
}

install_fonts() {
  if [ "$OS_TYPE" = "Darwin" ]; then
    brew tap homebrew/cask-fonts
    brew install --cask font-jetbrains-mono-nerd-font
  else
    mkdir -p ~/.local/share/fonts
    shopt -s nullglob
    local fonts
    fonts=(~/.dotfiles/fonts/*.ttf ~/.dotfiles/fonts/*.ttc ~/.dotfiles/fonts/*.otf)
    shopt -u nullglob
    if [ "${#fonts[@]}" -gt 0 ]; then
      cp "${fonts[@]}" ~/.local/share/fonts/
      fc-cache -f ~/.local/share/fonts 2>/dev/null || true
    elif command -v pacman >/dev/null 2>&1 && pacman -Qi ttf-jetbrains-mono-nerd >/dev/null 2>&1; then
      echo "✅ Using system font ttf-jetbrains-mono-nerd (from bootstrap-arch / pacman)."
    elif command -v dpkg-query >/dev/null 2>&1 && dpkg-query -W -f='${Status}' fonts-jetbrains-mono 2>/dev/null | grep -q 'ok installed'; then
      echo "✅ Using system font fonts-jetbrains-mono (from bootstrap-ubuntu / apt)."
    elif command -v pacman >/dev/null 2>&1; then
      echo "ℹ️  No fonts found in ~/.dotfiles/fonts/. Install JetBrains Nerd Font: sudo pacman -S ttf-jetbrains-mono-nerd"
    else
      echo "ℹ️  No fonts copied; add ttf/ttc/otf files under ~/.dotfiles/fonts/ or install a Nerd Font package."
    fi
  fi
}

get_system_info
install_fonts
