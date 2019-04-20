#!/bin/bash

if [ ! -h "$HOME/.gitconfig" ]
then
  ln -s "dotfiles/gitFile/gitconfig" "$HOME/.gitconfig"
fi
