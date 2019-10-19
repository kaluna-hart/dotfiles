# dotfile
## Usage
```sh
git clone https://github.com/faluna/dotfiles.git $HOME/dotfiles
cd dotfiles && bash symlink.sh
```
## alacritty
alacritty/alacritty.yml →  $HOME/.config/alacritty/alacritty.yml

## ctags
ctags/\*.ctags →  $HOME/.ctags.d/.\*.ctags

## fzf
fzf/fzf.zsh →  $HOME/.fzf.zsh

## neovim
nvim →  \${SDG\_CONFIG\_HOME:\-$HOME/.config}/nvim

## zsh
shells/zsh/\* →  $HOME/.\*

## starship
starship/starship.toml →  \${SDG\_CONFIG\_HOME:\-$HOME/.config}/starship.toml

## snippets
snippets →  $HOME/.snippets

## tmux
```sh
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
```
  
tmux/tmux.conf →  $HOME/.tmux.conf
