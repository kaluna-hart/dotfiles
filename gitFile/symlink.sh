#!/bin/bash

if [ ! -h "$HOME/.gitconfig" ]
then
  ln -s "dotfiles/gitFile/gitconfig" "$HOME/.gitconfig"
fi

if [ ! -h "$HOME/.commit_template" ]
then
  ln -s "dotfiles/gitFile/commit_template" "$HOME/.commit_template"
fi
