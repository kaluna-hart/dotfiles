#!/usr/local/bin/zsh

# git clone tpm
if [ ! -e "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
fi
