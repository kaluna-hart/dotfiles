#!/bin/bash

# git config symlink script
sh ~/dotfiles/gitFile/symlink.sh

# nvim derectory symlink
mkdir -p $HOME/.config
if [ ! -h "${XDG_CONFIG_HOME:-$HOME/.config}/nvim" ]
then
  ln -s "../dotfiles/nvim" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
fi

sh ~/dotfiles/alacritty/symlink.sh

sh ~/dotfiles/fzf/symlink.sh
# zsh rcfiles symlink script
zsh ~/dotfiles/shells/zsh/symlink.sh

zsh ~/dotfiles/ctags/symlink.sh

zsh ~/dotfiles/tmux/symlink.sh

# starship.toml symlink
if [ ! -h "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml" ]
then
  ln -s "../dotfiles/starship/starship.toml" "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
fi

# for snippets file
if [ ! -h "$HOME/.snippets" ]; then
  ln -s "dotfiles/snippets" "$HOME/.snippets"
fi

# for ghq
if [ ! -h "$HOME/.ghq" ]; then
  zsh ~/dotfiles/ghq/goenv.sh
  zsh ~/dotfiles/ghq/ghq.sh
fi

# icloud link
if [ ! -h "$HOME/iCloud" ]; then
  ln -s "Library/Mobile Documents/com~apple~CloudDocs" "$HOME/iCloud"
fi
