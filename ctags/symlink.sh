#!/bin/bash

mkdir -p $HOME/.ctags.d

setopt EXTENDED_GLOB
for tagsfile in "${HOME}"/dotfiles/ctags/^symlink.sh(.N); do
  if [ ! -h "${HOME}/.ctags.d/${tagsfile:t}" ]
  then
    ln -s "${HOME}/dotfiles/ctags/${tagsfile:t}" "${HOME}/.ctags.d/.${tagsfile:t}"
  fi
done
