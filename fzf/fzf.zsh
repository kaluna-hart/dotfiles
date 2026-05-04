# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

source <(fzf --zsh)

export FZF_CTRL_T_COMMAND="rg --files --hidden --follow --glob '!.git/*' 2>/dev/null"
export FZF_CTRL_T_OPTS='--height 80% --border --layout=reverse --preview "bat --color=always --line-range :100 {}"'
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS='--height 80% --border --layout=reverse --preview "bat --color=always --line-range :100 {}"'
