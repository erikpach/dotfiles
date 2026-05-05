#!/bin/bash

input=$(cat)

# Directory - prefer top-level cwd, fallback workspace.current_dir
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')

# Context
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# Cost
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
cost_fmt=$(printf '%.2f' "$cost" 2>/dev/null || echo "0.00")

# Model short name
model_id=$(echo "$input" | jq -r '.model.id // ""')
case "$model_id" in
  *opus*)   model_short="opus" ;;
  *sonnet*) model_short="sonnet" ;;
  *haiku*)  model_short="haiku" ;;
  *)        model_short="" ;;
esac

# Effort level (skip if default "medium")
effort=$(echo "$input" | jq -r '.effort.level // ""')
[ "$effort" = "medium" ] && effort=""

# Worktree name
worktree=$(echo "$input" | jq -r '.worktree.name // ""')

# Caveman badge
caveman_flag="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"
caveman_badge=""
if [ -f "$caveman_flag" ] && [ ! -L "$caveman_flag" ]; then
  cave_mode=$(head -c 64 "$caveman_flag" 2>/dev/null | tr -d '\n\r' | tr -cd 'a-z0-9-')
  case "$cave_mode" in
    off|lite|full|ultra|wenyan-lite|wenyan|wenyan-full|wenyan-ultra|commit|review|compress)
      if [ -z "$cave_mode" ] || [ "$cave_mode" = "full" ]; then
        caveman_badge=$(printf '\033[38;5;172m[CAVEMAN]\033[0m')
      else
        SUFFIX=$(printf '%s' "$cave_mode" | tr '[:lower:]' '[:upper:]')
        caveman_badge=$(printf '\033[38;5;172m[CAVEMAN:%s]\033[0m' "$SUFFIX")
      fi
      ;;
  esac
fi

# Context color
if [ "$ctx_pct" -ge 75 ]; then
  ctx_color='\033[01;31m'   # red
elif [ "$ctx_pct" -ge 50 ]; then
  ctx_color='\033[01;33m'   # yellow
elif [ "$ctx_pct" -ge 25 ]; then
  ctx_color='\033[00;33m'   # dim yellow
else
  ctx_color='\033[01;32m'   # green
fi

# Git info
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  repo_name=$(basename "$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || echo "$cwd")")
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  dirty=$(git -C "$cwd" status --porcelain 2>/dev/null | head -1)
  [ -n "$dirty" ] && branch_suffix="*" || branch_suffix=""

  printf '\033[01;36m%s\033[00m\033[00;37m(%s%s)\033[00m' \
    "$repo_name" "$git_branch" "$branch_suffix"
else
  printf '\033[01;36m%s\033[00m' "${cwd:-?}"
fi

# Context
printf ' | ctx:%b%s%%\033[00m' "$ctx_color" "$ctx_pct"

# Cost (only show if non-zero)
if [ "$cost_fmt" != "0.00" ]; then
  printf ' | \033[00;37m$%s\033[00m' "$cost_fmt"
fi

# Model
if [ -n "$model_short" ]; then
  printf ' | \033[00;35m%s\033[00m' "$model_short"
fi

# Effort (non-default only)
if [ -n "$effort" ]; then
  printf ' | \033[00;36m%s\033[00m' "$effort"
fi

# Worktree
if [ -n "$worktree" ]; then
  printf ' | \033[00;34mwt:%s\033[00m' "$worktree"
fi

# Caveman badge
if [ -n "$caveman_badge" ]; then
  printf ' %b' "$caveman_badge"
fi

printf '\033[00m'
