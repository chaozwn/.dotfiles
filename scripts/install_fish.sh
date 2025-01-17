#!/bin/bash

# install fish
brew install fish
sudo sh -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
chsh -s /opt/homebrew/bin/fish

# install fish dependencies
brew install fastfetch
brew install gum
brew install hub
brew install fd
brew install grc
brew install bat
brew install nvm
brew install numbat
brew install htop
brew install mosh
brew install tmuxinator
brew install eza
brew install ncdu
brew install bottom

# npm
npm install -g yarn pnpm devmoji ultra
