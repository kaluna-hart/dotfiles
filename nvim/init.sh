#!/usr/local/bin/zsh

############################
# anyenv setup
# load zprofile
source $HOME/.zprofile

# initialize anyenv
if [ ! -e "${XDG_CONFIG_HOME:-$HOME/.config}/anyenv" ]; then
  anyenv install --init
fi

# make directory $HOME/.anyenv/plugins
mkdir -p $HOME/.anyenv/plugins

# install anyenv plugins
if [ ! -e "$HOME/.anyenv/plugins/anyenv-update" ]; then
  git clone --depth 1 https://github.com/znz/anyenv-update.git $HOME/.anyenv/plugins/anyenv-update
fi

if [ ! -e "$HOME/.anyenv/plugins/anyenv-git" ]; then
  git clone --depth 1 https://github.com/znz/anyenv-git.git $HOME/.anyenv/plugins/anyenv-git
fi
############################

############################
# pyenv setup

# install pyenv by using anyenv
anyenv install pyenv
anyenv install nodenv

# reload .zprofile
source $HOME/.zprofile

# install the addtional SDK headers
# sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /;

# install pyenv-virtualenv by using homebrew
brew install pyenv-virtualenv

# install python3.7.3 by using pyenv and createvirtualenv neovim3
pyenv install 3.7.4
pyenv virtualenv 3.7.4 neovim3

# install python2.7.16 by using pyenv and createvirtualenv neovim2
# pyenv install 2.7.16
# pyenv virtualenv 2.7.16 neovim2

# install node
nodenv install 12.7.0

# restart shell
# exec $SHELL -l

zsh ~/dotfiles/nvim/activate.sh
