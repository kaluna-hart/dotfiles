#!/bin/bash

if [ ! -h "$HOME/.eslinrc.json" ]
then
  ln -s "../dotfiles/eslint/eslinrc.json" "$HOME/.eslinrc.json"
fi
