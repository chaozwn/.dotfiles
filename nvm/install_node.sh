#!/usr/bin/env fish

set -l script_dir (path dirname (status filename))
set -l ver (string trim (cat "$script_dir/VERSION"))

nvm install $ver

# 安装全局 npm 包
npm install -g yarn pnpm devmoji ultra tree-sitter-cli neovim @styled/typescript-styled-plugin git-cz
