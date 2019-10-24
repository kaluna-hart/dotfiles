#!/bin/zsh

setopt EXTENDED_GLOB
for rcfile in "${HOME}"/dotfiles/shells/zsh/^symlink.sh(.N); do
  if [ ! -h "${ZDOTDIR:-$HOME}/.${rcfile:t}" ]
  then
    ln -s "dotfiles/shells/zsh/${rcfile:t}" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
  fi
done
