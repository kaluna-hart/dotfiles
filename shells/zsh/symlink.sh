#!/usr/bin/zsh

setopt EXTENDED_GLOB
for rcfile in ./^README.md(.N); do
  if [ ! -h "${ZDOTDIR:-$HOME}/.${rcfile:t}" ]
  then
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
  fi
done
