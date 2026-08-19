#!/usr/bin/env bash
input=$(cat)

# Catppuccin Mocha 24-bit colors
CLR_BLUE='\033[38;2;137;180;250m'    # #89b4fa  git branch
CLR_FG='\033[38;2;205;214;244m'      # #cdd6f4  model name, usage value
CLR_SUBTEXT='\033[38;2;186;194;222m' # #bac2de  CTX: and Usage: labels
CLR_GREEN='\033[38;2;166;227;161m'   # #a6e3a1  ctx < 75%
CLR_YELLOW='\033[38;2;249;226;175m'  # #f9e2af  ctx 75-89%
CLR_RED='\033[38;2;243;139;168m'     # #f38ba8  ctx 90%+
CLR_RESET='\033[0m'

# Git branch (skip optional locks)
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$(echo "$input" | jq -r '.workspace.current_dir')" rev-parse --abbrev-ref HEAD 2>/dev/null)

# Model display name
model=$(echo "$input" | jq -r '.model.display_name // empty')

# Context usage percentage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Session rate limit (5-hour)
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# Line 1: git branch
if [ -n "$branch" ]; then
  printf "${CLR_BLUE}\ue0a0 %s${CLR_RESET}\n" "$branch"
fi

# Line 2: model  CTX: X%  Usage: X%
line2_parts=()

[ -n "$model" ] && line2_parts+=("$(printf "${CLR_FG}%s${CLR_RESET}" "$model")")

if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  if [ "$used_int" -ge 90 ]; then
    ctx_color="$CLR_RED"
  elif [ "$used_int" -ge 75 ]; then
    ctx_color="$CLR_YELLOW"
  else
    ctx_color="$CLR_GREEN"
  fi
  line2_parts+=("$(printf "${CLR_SUBTEXT}CTX:${CLR_RESET} ${ctx_color}%.0f%%${CLR_RESET}" "$used_pct")")
fi

[ -n "$five_pct" ] && line2_parts+=("$(printf "${CLR_SUBTEXT}Usage:${CLR_RESET} ${CLR_FG}%.0f%%${CLR_RESET}" "$five_pct")")

if [ ${#line2_parts[@]} -gt 0 ]; then
  IFS='  '
  printf '%s' "${line2_parts[*]}"
fi
