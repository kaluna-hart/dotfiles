#!/bin/bash

if [ ! -h "$HOME/.fzf.zsh" ]; then
  ln -s "$HOME/dotfiles/fzf/fzf.zsh" "$HOME/.fzf.zsh"
fi
