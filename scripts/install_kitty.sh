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
    cp ~/.dotfiles/fonts/*.ttf ~/.local/share/fonts/
  fi
}
