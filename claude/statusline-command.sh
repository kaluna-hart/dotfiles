#!/bin/sh
input=$(cat)

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
RESET='\033[0m'

# Directory
cwd=$(printf '%s' "$input" | jq -r '.cwd // ""')
if [ -n "$cwd" ]; then
  dir=$(basename "$cwd")
else
  dir=""
fi

# Git branch
branch=""
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" -c gc.auto=0 symbolic-ref --short HEAD 2>/dev/null || true)
fi

# Model
model=$(printf '%s' "$input" | jq -r '.model.display_name // ""')

# Context usage
ctx=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null || true)
if [ -n "$ctx" ]; then
  ctx_int=$(printf '%.0f' "$ctx" 2>/dev/null || echo "0")
  if [ "$ctx_int" -ge 80 ]; then
    ctx_color=$RED
  elif [ "$ctx_int" -ge 50 ]; then
    ctx_color=$YELLOW
  else
    ctx_color=$GRAY
  fi
  ctx_str="${ctx_color}ctx:${ctx_int}%${RESET}"
else
  ctx_str=""
fi

# Rate limit: 5 hour
five=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null || true)
if [ -n "$five" ]; then
  five_int=$(printf '%.0f' "$five" 2>/dev/null || echo "0")
  if [ "$five_int" -ge 80 ]; then
    five_color=$RED
  elif [ "$five_int" -ge 50 ]; then
    five_color=$YELLOW
  else
    five_color=$GRAY
  fi
  five_str="${five_color}5h:${five_int}%${RESET}"
else
  five_str=""
fi

# Rate limit: 7 day
seven=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null || true)
if [ -n "$seven" ]; then
  seven_int=$(printf '%.0f' "$seven" 2>/dev/null || echo "0")
  if [ "$seven_int" -ge 80 ]; then
    seven_color=$RED
  elif [ "$seven_int" -ge 50 ]; then
    seven_color=$YELLOW
  else
    seven_color=$GRAY
  fi
  seven_str="${seven_color}7d:${seven_int}%${RESET}"
else
  seven_str=""
fi

# Build output
out=""
[ -n "$dir" ]     && out="${out}${CYAN}${dir}${RESET}"
[ -n "$branch" ]  && out="${out}  ${GREEN}${branch}${RESET}"
[ -n "$model" ]   && out="${out}  ${BLUE}${model}${RESET}"
[ -n "$ctx_str" ] && out="${out}  ${ctx_str}"
[ -n "$five_str" ] && out="${out}  ${five_str}"
[ -n "$seven_str" ] && out="${out}  ${seven_str}"

printf '%b\n' "$out"
