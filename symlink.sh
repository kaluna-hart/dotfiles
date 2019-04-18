#!/usr/bin/bash

# git config symlink script
./gitFile/symlink.sh

# nvim derectory symlink
mkdir -p $HOME/.config
if [ ! -h ${XDG_CONFIG_HOME:-$HOME}/.config/nvim ]
then
  ln -s "./nvim" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
fi

# zsh rcfiles symlink script
./shells/zsh/symlink.sh
