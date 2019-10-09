#!/usr/local/bin/zsh

# reload .zprofile
source $HOME/.zprofile

# install ghq
brew install ghq

# install z by using ghq
ghq get https://github.com/rupa/z.git
