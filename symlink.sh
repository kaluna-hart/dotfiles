#!/bin/zsh

# Usage: ./symlink.sh [--dry-run]

created=0
skipped=0
overwritten=0
errors=0

dry_run=false
if [[ "$1" == "--dry-run" ]]; then
  dry_run=true
fi

create_symlink() {
  local source="$1"
  local target="$2"

  if [[ -e "$target" && ! -h "$target" ]]; then
    if $dry_run; then
      echo "BACKUP: $target -> ${target}.bak"
      echo "CREATE: $target -> $source"
      ((created++))
      return 0
    fi
    mv "$target" "${target}.bak" 2>/dev/null
    echo "BACKUP: $target -> ${target}.bak"
  fi

  if [[ -h "$target" ]]; then
    local current_target
    current_target=$(readlink "$target" 2>/dev/null)
    if [[ "$current_target" == "$source" ]]; then
      echo "SKIP: $target -> $source (already correct)"
      ((skipped++))
      return 0
    fi

    if $dry_run; then
      echo "OVERWRITE: $target -> $source (currently: $current_target)"
      ((overwritten++))
      return 0
    fi
    rm -f "$target"
    ln -s "$source" "$target" 2>/dev/null
    if [[ $? -eq 0 ]]; then
      echo "OVERWRITE: $target -> $source"
      ((overwritten++))
      return 0
    else
      echo "ERROR: Failed to create symlink $target -> $source"
      ((errors++))
      return 1
    fi
  fi

  if $dry_run; then
    echo "CREATE: $target -> $source"
    ((created++))
    return 0
  fi

  ln -s "$source" "$target" 2>/dev/null
  if [[ $? -eq 0 ]]; then
    echo "CREATE: $target -> $source"
    ((created++))
    return 0
  else
    echo "ERROR: Failed to create symlink $target -> $source"
    ((errors++))
    return 1
  fi
}

ensure_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    if $dry_run; then
      echo "MKDIR: $dir"
    else
      mkdir -p "$dir" 2>/dev/null
    fi
  fi
}

echo "========================================="
echo " Symlink Setup"
if $dry_run; then
  echo " (DRY RUN - no changes will be made)"
fi
echo "========================================="
echo ""

# -------------------------------------------
# Git
# -------------------------------------------
echo "--- Git ---"
create_symlink "$HOME/dotfiles/gitFile/gitconfig" "$HOME/.gitconfig"
create_symlink "$HOME/dotfiles/gitFile/commit_template" "$HOME/.commit_template"
create_symlink "$HOME/dotfiles/gitFile/gitconfig_snowhite" "$HOME/.gitconfig_snowhite"
create_symlink "$HOME/dotfiles/gitFile/gitconfig_rakuweb" "$HOME/.gitconfig_rakuweb"
echo ""

# -------------------------------------------
# Neovim
# -------------------------------------------
echo "--- Neovim ---"
ensure_dir "$HOME/.config"
create_symlink "$HOME/dotfiles/nvim" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
echo ""

# -------------------------------------------
# Alacritty
# -------------------------------------------
echo "--- Alacritty ---"
ensure_dir "$HOME/.config/alacritty"
create_symlink "$HOME/dotfiles/alacritty/alacritty.yml" "${XDG_CONFIG_HOME:-$HOME/.config}/alacritty/alacritty.yml"
echo ""

# -------------------------------------------
# FZF
# -------------------------------------------
echo "--- FZF ---"
create_symlink "$HOME/dotfiles/fzf/fzf.zsh" "$HOME/.fzf.zsh"
echo ""

# -------------------------------------------
# Zsh
# -------------------------------------------
echo "--- Zsh ---"
setopt EXTENDED_GLOB
for rcfile in "$HOME"/dotfiles/shells/zsh/^symlink.sh(.N); do
  create_symlink "$HOME/dotfiles/shells/zsh/${rcfile:t}" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
echo ""

# -------------------------------------------
# Ctags
# -------------------------------------------
echo "--- Ctags ---"
ensure_dir "$HOME/.ctags.d"
for tagsfile in "$HOME"/dotfiles/ctags/^symlink.sh(.N); do
  # No dot prefix on target filename
  create_symlink "$HOME/dotfiles/ctags/${tagsfile:t}" "$HOME/.ctags.d/${tagsfile:t}"
done
echo ""

# -------------------------------------------
# Tmux
# -------------------------------------------
echo "--- Tmux ---"
create_symlink "$HOME/dotfiles/tmux/tmux.conf" "$HOME/.tmux.conf"
echo ""

# -------------------------------------------
# Starship
# -------------------------------------------
echo "--- Starship ---"
create_symlink "$HOME/dotfiles/starship/starship.toml" "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
echo ""

# -------------------------------------------
# Snippets
# -------------------------------------------
echo "--- Snippets ---"
create_symlink "$HOME/dotfiles/snippets" "$HOME/.snippets"
echo ""

# -------------------------------------------
# ESLint (fixed typo: .eslinrc.json -> .eslintrc.json)
# -------------------------------------------
echo "--- ESLint ---"
create_symlink "$HOME/dotfiles/eslint/eslintrc.json" "$HOME/.eslintrc.json"
echo ""

# -------------------------------------------
# iCloud & Volumes
# -------------------------------------------
echo "--- iCloud & Volumes ---"
create_symlink "Library/Mobile Documents/com~apple~CloudDocs" "$HOME/iCloud"
create_symlink "/Volumes" "$HOME/Volumes"
echo ""

# -------------------------------------------
# Claude
# -------------------------------------------
echo "--- Claude ---"
ensure_dir "$HOME/.claude"
create_symlink "$HOME/dotfiles/claude/settings.json" "$HOME/.claude/settings.json"
create_symlink "$HOME/dotfiles/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
create_symlink "$HOME/dotfiles/claude/agents" "$HOME/.claude/agents"
create_symlink "$HOME/dotfiles/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
echo ""

# -------------------------------------------
# Codex
# -------------------------------------------
echo "--- Codex ---"
ensure_dir "$HOME/.codex"
create_symlink "$HOME/dotfiles/codex/config.toml" "$HOME/.codex/config.toml"
create_symlink "$HOME/dotfiles/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
create_symlink "$HOME/dotfiles/codex/rules" "$HOME/.codex/rules"
create_symlink "$HOME/dotfiles/codex/agents" "$HOME/.codex/agents"
echo ""

# -------------------------------------------
# Gemini
# -------------------------------------------
echo "--- Gemini ---"
ensure_dir "$HOME/.gemini"
create_symlink "$HOME/dotfiles/gemini/settings.json" "$HOME/.gemini/settings.json"
create_symlink "$HOME/dotfiles/gemini/GEMINI.md" "$HOME/.gemini/GEMINI.md"
echo ""

# -------------------------------------------
# Ghostty
# -------------------------------------------
echo "--- Ghostty ---"
ensure_dir "$HOME/.config/ghostty"
create_symlink "$HOME/dotfiles/ghostty/config" "$HOME/.config/ghostty/config"
echo ""

# -------------------------------------------
# Opencode
# -------------------------------------------
echo "--- Opencode ---"
ensure_dir "$HOME/.config/opencode"
create_symlink "$HOME/dotfiles/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
create_symlink "$HOME/dotfiles/opencode/oh-my-opencode.json" "$HOME/.config/opencode/oh-my-opencode.json"
echo ""

# -------------------------------------------
# Tmux init (tpm)
# -------------------------------------------
echo "--- Tmux Init ---"
if $dry_run; then
  echo "DRY RUN: Would execute: zsh $HOME/dotfiles/tmux/init.sh"
else
  zsh "$HOME/dotfiles/tmux/init.sh"
fi
echo ""

# -------------------------------------------
# Summary
# -------------------------------------------
echo "========================================="
echo " Summary"
echo "========================================="
echo " Created:   $created"
echo " Skipped:   $skipped"
echo " Overwrite: $overwritten"
echo " Errors:    $errors"
echo "========================================="

if (( errors > 0 )); then
  echo "WARNING: $errors error(s) occurred. Check output above."
  exit 1
fi

exit 0
