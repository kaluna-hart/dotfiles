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

./fzf/symlink.sh
# zsh rcfiles symlink script
zsh ./shells/zsh/symlink.sh

zsh ./ctags/symlink.sh

./tmux/symlink.sh

# starship.toml symlink
if [ ! -h "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml" ]
then
  ln -s "../dotfiles/starship/starship.toml" "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
fi

# for snippets file
if [ ! -h "$HOME/.snippets" ]; then
  ln -s "dotfiles/snippets" "$HOME/.snippets"
fi
