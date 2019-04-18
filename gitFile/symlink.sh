#!/usr/bin/bash

if [ ! -h "$HOME/.gitconfig" ]
then
  ls -s "./gitconfig" "$HOME/.gitconfig"
fi
