#!/usr/local/bin/zsh

#########################3
# Setup goenv by using anyenv
###########################3

# load zprofile
source $HOME/.zprofile

# install goenv by using anyenv
anyenv install goenv

# reload .zprofile
source $HOME/.zprofile

# install go recently latest version 
goenv install 1.12.6
goenv global 1.12.6
