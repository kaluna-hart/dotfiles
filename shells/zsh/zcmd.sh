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

# for gh completion
eval "$(gh completion -s zsh)"
