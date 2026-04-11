#!/bin/bash

# 获取系统相关信息
# Get system information
get_system_info() {
  OS_TYPE="$(uname)"
}

# 根据系统类型确定 brew 路径
# Determine brew path based on OS
install_fonts() {
  if [ "$OS_TYPE" = "Darwin" ]; then
    brew tap homebrew/cask-fonts
    brew install --cask font-jetbrains-mono-nerd-font
  else
    mkdir -p ~/.local/share/fonts
    shopt -s nullglob
    local ttf
    ttf=(~/.dotfiles/fonts/*.ttf)
    shopt -u nullglob
    if [ "${#ttf[@]}" -gt 0 ]; then
      cp "${ttf[@]}" ~/.local/share/fonts/
      fc-cache -f ~/.local/share/fonts 2>/dev/null || true
    elif command -v pacman >/dev/null 2>&1 && pacman -Qi ttf-jetbrains-mono-nerd >/dev/null 2>&1; then
      echo "✅ Using system font ttf-jetbrains-mono-nerd (from bootstrap-arch / pacman)."
    elif command -v pacman >/dev/null 2>&1; then
      echo "ℹ️  No ~/.dotfiles/fonts/*.ttf found. Install JetBrains Nerd Font: sudo pacman -S ttf-jetbrains-mono-nerd"
    else
      echo "ℹ️  No ~/.dotfiles/fonts/*.ttf copied; add fonts under ~/.dotfiles/fonts/ or install a Nerd Font package."
    fi
  fi
}

get_system_info 
install_fonts 
