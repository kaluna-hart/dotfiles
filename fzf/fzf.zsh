# Setup fzf
# ---------
if [[ ! "$PATH" == ${HOME}/.local/share/rtx/installs/fzf/0.35.1/bin* ]]; then
  # Key bindings
  source "${HOME}/.local/share/rtx/installs/fzf/0.35.1/shell/key-bindings.zsh"
# Auto-completion
  source "${HOME}/.local/share/rtx/installs/fzf/0.35.1/shell/completion.zsh"
fi

export FZF_CTRL_T_COMMAND="rg --files --hidden --follow --glob '!.git/*' 2>/dev/null"
export FZF_CTRL_T_OPTS='--height 80% --border --layout=reverse --preview "bat --color=always --line-range :100 {}"'
# export FZF_CTRL_T_OPTS='--height 80% --border --layout=reverse --preview "bat --color=always --style=header,grid --line-range :100 {}"'
# use ripgrep
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS='--height 80% --border --layout=reverse --preview "bat --color=always --line-range :100 {}"'
# export FZF_DEFAULT_OPTS='--height 80% --border --layout=reverse --preview "bat --color=always --style=header,grid --line-range :100 {}"'
