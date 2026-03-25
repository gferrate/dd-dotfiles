#!/usr/bin/env bash
set -euo pipefail

DOTFILES_PATH="$HOME/dotfiles"

# Symlink dotfiles to home directory
find "$DOTFILES_PATH" -type f -path "$DOTFILES_PATH/.*" |
while read -r df; do
  link="${df/$DOTFILES_PATH/$HOME}"
  mkdir -p "$(dirname "$link")"
  ln -sf "$df" "$link"
done

# Install tools
sudo apt-get update -qq
sudo apt-get install -y -qq neovim gh autojump
