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
omps() {
    local root pass_env
    local -a env_args

    root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
        echo "Error: Git repository の中で実行してください"
        return 1
    }

    pass_env="HERDR_ENV:HERDR_BIN_PATH:HERDR_PANE_ID:HERDR_SOCKET_PATH:HERDR_TAB_ID:HERDR_WORKSPACE_ID"

    env_args=(
        "OMP_SANDBOX_WORKSPACE=$root"
        "OMP_SANDBOX_YOLO=1"
    )

    if [[ "${OMPS_AWS_MODE:-0}" == "1" ]]; then
        # Bedrock用：AWSファイルの読み取りを許可
        env_args+=(
            "OMP_SANDBOX_EXTRA_READ=$HOME/.aws"
            "OMP_SANDBOX_CONFIRM_SENSITIVE_READ=1"
        )
    else
        # 通常用：AWSファイルへのアクセスを禁止
        env_args+=(
            "OMP_SANDBOX_EXTRA_READ="
            "OMP_SANDBOX_CONFIRM_SENSITIVE_READ=0"
            "AWS_SHARED_CREDENTIALS_FILE=/dev/null"
            "AWS_CONFIG_FILE=/dev/null"
        )
        pass_env="${pass_env}:AWS_SHARED_CREDENTIALS_FILE:AWS_CONFIG_FILE"
    fi

    /usr/bin/env "${env_args[@]}" \
        "OMP_SANDBOX_PASS_ENV=$pass_env" \
        "$HOME/.omp/sandbox/omp-sandboxed" \
        --config "$HOME/.omp/agent/sandbox.yml" "$@"
}

ompsaws() {
    OMPS_AWS_MODE=1 omps "$@"
}

# for gh completion
eval "$(gh completion -s zsh)"
