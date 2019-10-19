#!/bin/bash

if [ ! -h "$HOME/.tmux.conf" ]; then
  ln -s "dotfiles/tmux/tmux.conf" "$HOME/.tmux.conf"
fi
