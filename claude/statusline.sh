#!/usr/bin/env bash
# Claude Code status line: model · directory · git branch · context used · 5h limit.
input="$(cat)"

field() { jq -r "$1 // empty" <<<"$input" 2>/dev/null; }

model="$(field .model.display_name)"
dir="$(field .workspace.current_dir)"
[[ -z "$dir" ]] && dir="$(field .cwd)"
context="$(field .context_window.used_percentage)"
limit="$(field .rate_limits.five_hour.used_percentage)"
branch="$(git -C "${dir:-.}" branch --show-current 2>/dev/null)"

dim=$'\033[2m'
blue=$'\033[34m'
magenta=$'\033[35m'
yellow=$'\033[33m'
red=$'\033[31m'
reset=$'\033[0m'

level() {
    local pct="${1%.*}"
    if [[ "$pct" -ge 80 ]]; then printf '%s' "$red"
    elif [[ "$pct" -ge 50 ]]; then printf '%s' "$yellow"
    else printf '%s' "$dim"
    fi
}

out="${blue}${model:-Claude}${reset} ${dim}·${reset} ${dir##*/}"
[[ -n "$branch" ]] && out+=" ${dim}·${reset} ${magenta}${branch}${reset}"
[[ -n "$context" ]] && out+=" ${dim}·${reset} $(level "$context")ctx ${context%.*}%${reset}"
[[ -n "$limit" ]] && out+=" ${dim}·${reset} $(level "$limit")5h ${limit%.*}%${reset}"
printf '%s\n' "$out"
