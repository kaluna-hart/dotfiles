# fzf function
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
    -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# fda - fd including hidden directories
fda() {
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir"
}

# nvim fzf
fv() {
  local file
  file=$(find ${1:-.} -path '\.*' \
    -type f -print 2> /dev/null | fzf +m) &&
    nvim "$file"
}

# fzf + z 
fzf-z-search() {
  local res=$(z | sort -rn | cut -c 12- | fzf)
  if [ -n "$res" ]; then
    BUFFER+="cd \"$res\""
    zle accept-line
  else
    return 1
  fi
}

# for oh my pi
omps () {
    local root
    root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
        echo "Error: Git repository の中で omps を実行してください"
        return 1
    }

    OMP_SANDBOX_WORKSPACE="$root" \
    OMP_SANDBOX_YOLO=1 \
    OMP_SANDBOX_PASS_ENV="HERDR_ENV:HERDR_BIN_PATH:HERDR_PANE_ID:HERDR_SOCKET_PATH:HERDR_TAB_ID:HERDR_WORKSPACE_ID" \
    "$HOME/.omp/sandbox/omp-sandboxed" \
    --config "$HOME/.omp/agent/sandbox.yml" "$@"
}

# for gh completion
eval "$(gh completion -s zsh)"
