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
# omps は ~/.omp/sandbox/omps-launcher に委譲する。
# ランチャーが担当: Git worktree 検出 / 起動時限定の読み取り許可 (OMPS_EXTRA_READ) /
# AWS モード / HERDR 環境変数転送 / クリーン環境 / Seatbelt 適用と失敗時中止。
omps() {
    local launcher="$HOME/.omp/sandbox/omps-launcher"
    if [[ ! -x "$launcher" ]]; then
        echo "Error: omps-launcher が見つかりません: $launcher" >&2
        return 1
    fi
    OMP_SANDBOX_YOLO=1 "$launcher" "$@"
}

ompsaws() {
    OMPS_AWS_MODE=1 omps "$@"
}

# for gh completion
eval "$(gh completion -s zsh)"
