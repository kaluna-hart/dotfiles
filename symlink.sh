#!/bin/bash

# git config symlink script
sh ./gitFile/symlink.sh

# nvim derectory symlink
mkdir -p $HOME/.config
if [ ! -h ${XDG_CONFIG_HOME:-$HOME}/.config/nvim ]
then
  ln -s "../dotfiles/nvim" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
fi

./alacritty/symlink.sh

# zsh rcfiles symlink script
zsh ./shells/zsh/symlink.sh
