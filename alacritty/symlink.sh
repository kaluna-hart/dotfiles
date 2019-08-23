#!/bin/bash

# alacritty config deirectory
mkdir -p $HOME/.config/alacritty

if [ ! -h "${XDG_CONFIG_HOME:-$HOME/.config}/alacritty/alacritty.yml" ]; then
  ln -s "$HOME/dotfiles/alacritty/alacritty.yml" "${XDG_CONFIG_HOME:-$HOME/.config}/alacritty/alacritty.yml"
fi

if [ ! -h "$HOME/.alacritty.yml" ]; then
  ln -s "$HOME/dotfiles/alacritty/alacritty.yml" "$HOME/.alacritty.yml"
fi
