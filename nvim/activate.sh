#!/usr/local/bin/zsh

#######################3
# init.sh 実行後，シェルリスタートする
# その後実行
source $HOME/.zprofile

# neovim3 構築
pyenv activate neovim3
pip install --upgrade pip
pip3 install --upgrade neovim
source deactivate neovim3

# neovim2 構築
pyenv activate neovim2
pip install --upgrade pip
pip2 install --upgrade neovim
source deactivate neovim2
