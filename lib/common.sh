#!/usr/bin/env bash
# lib/common.sh — shared utilities used by every installer module.
# Meant to be sourced, not executed directly.

# --- Colors ----------------------------------------------------------------
export black='\e[0;30m'
export red='\e[0;31m'
export green='\e[0;32m'
export orange='\e[0;33m'
export blue='\e[0;34m'
export purple='\e[0;35m'
export cyan='\e[0;36m'
export white='\e[0;37m'
export nc='\e[0m' # No Color

# --- Logging ---------------------------------------------------------------
log()  { echo -e "${orange}$*${nc}"; }
info() { echo -e "${cyan}  $*${nc}"; }
ok()   { echo -e "${green}$*${nc}"; }
warn() { echo -e "${purple}! $*${nc}"; }
err()  { echo -e "${red}✗ $*${nc}" >&2; }

# --- Helpers ---------------------------------------------------------------

# has_cmd <command>: returns 0 if the command exists in PATH.
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# DOTFILES_DIR: repo root (exported from install.sh; falls back to the cwd).
: "${DOTFILES_DIR:=$(pwd)}"

# link_file <src> <dest>
# Creates a symlink from <src> (inside the repo) to <dest>.
# - Creates the parent directory of <dest> if missing.
# - If <dest> already exists and is NOT already the correct symlink, it is
#   backed up to <dest>.bak-<timestamp> before being replaced.
# - Idempotent: does nothing if the symlink already points to <src>.
link_file() {
    local src="$1" dest="$2"
    if [[ ! -e "$src" ]]; then
        err "Source does not exist: $src"
        return 1
    fi
    mkdir -p "$(dirname "$dest")"

    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        info "ok (already linked): $dest"
        return 0
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        local backup
        backup="${dest}.bak-$(date +%Y%m%d%H%M%S)"
        warn "Backing up $dest -> $backup"
        mv "$dest" "$backup"
    fi

    ln -s "$src" "$dest"
    ok "  linked: $dest -> $src"
}

# ask_yes_no <question>: returns 0 for "yes" (empty input / Enter defaults to yes).
ask_yes_no() {
    local prompt="$1" input
    echo -e "\n${white}${prompt} (Y/n)${nc}"
    read -r input
    [[ -z "$input" || "$input" =~ ^[Yy]$ ]]
}
