#!/usr/local/bin/zsh

#######################3
# init.sh 実行後，シェルリスタートする
# その後実行
source $HOME/.zprofile

# neovim3 構築
pyenv activate neovim3
pip install --upgrade pip
pip install --upgrade pynvim
source deactivate neovim3

# neovim2 構築
pyenv activate neovim
pip install --upgrade pip
pip install --upgrade pynvim
source deactivate neovim2
