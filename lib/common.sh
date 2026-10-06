#!/usr/bin/env bash
# lib/common.sh — shared utilities used by every installer module.
# Meant to be sourced, not executed directly. Must stay bash 3.2 compatible
# (the bash that ships with macOS).

# --- Colors ----------------------------------------------------------------
export black='\033[0;30m'
export red='\033[0;31m'
export green='\033[0;32m'
export orange='\033[0;33m'
export blue='\033[0;34m'
export purple='\033[0;35m'
export cyan='\033[0;36m'
export white='\033[0;37m'
export nc='\033[0m' # No Color

# --- Output ----------------------------------------------------------------
bold='\033[1m'
dim='\033[2m'
WARNINGS=()
PENDING=()

log()  { echo -e "${cyan}  ›${nc} $*"; }
info() { echo -e "${dim}    $*${nc}"; }
ok()   { echo -e "${green}  ✓${nc} $*"; }
warn() { echo -e "${orange}  !${nc} $*"; WARNINGS+=("$*"); }
err()  { echo -e "${red}  ✗ $*${nc}" >&2; }

# pending <text>: a manual step left for the user, listed in the final summary.
pending() { PENDING+=("$*"); }

STEP=0
STEPS=0
# section <title> <subtitle>: numbered header for each component.
section() {
    STEP=$((STEP + 1))
    echo -e "\n${bold}${blue}━━ [${STEP}/${STEPS}] $1${nc} ${dim}$2${nc}"
}

summary() {
    local item
    echo -e "\n${bold}━━ Summary${nc}"
    if [[ "${#WARNINGS[@]}" -eq 0 ]]; then
        ok "No warnings."
    else
        for item in "${WARNINGS[@]}"; do echo -e "${orange}  !${nc} $item"; done
    fi
    if [[ "${#PENDING[@]}" -gt 0 ]]; then
        echo -e "\n${bold}  Still to do by hand${nc}"
        for item in "${PENDING[@]}"; do echo -e "${blue}  →${nc} $item"; done
    fi
    echo -e "\n${dim}  Check everything: dotfiles doctor   ·   Undo: dotfiles rescue / dotfiles uninstall${nc}"
}

# --- Run modes ---------------------------------------------------------------
: "${DRY_RUN:=0}"
: "${ASSUME_YES:=0}"

# run_cmd <cmd...>: executes the command, or only prints it in dry-run mode.
run_cmd() {
    if [[ "$DRY_RUN" == 1 ]]; then
        info "[dry-run] $*"
        return 0
    fi
    "$@"
}

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

    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        info "ok (already linked): $dest"
        return 0
    fi

    run_cmd mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" || -L "$dest" ]]; then
        local backup
        backup="${dest}.bak-$(date +%Y%m%d%H%M%S)"
        warn "Backing up $dest -> $backup"
        run_cmd mv "$dest" "$backup"
    fi

    run_cmd ln -s "$src" "$dest"
    state_add links "$dest"
    [[ "$DRY_RUN" == 1 ]] || ok "  linked: $dest -> $src"
}

# read_pkgs <file>: prints the packages (ignoring comments and blank lines).
read_pkgs() {
    sed -e 's/#.*//' -e 's/[[:space:]]*$//' "$1" | grep -v '^[[:space:]]*$' | tr '\n' ' '
}

# ask_yes_no <question>: returns 0 for "yes" (empty input / Enter defaults to yes).
ask_yes_no() {
    local prompt="$1" input
    if [[ "$ASSUME_YES" == 1 ]]; then
        return 0
    fi
    echo -ne "\n${prompt} ${dim}[Y/n]${nc} "
    read -r input
    [[ -z "$input" || "$input" =~ ^[Yy]$ ]]
}

# as_root <cmd...>: runs the command as root (directly when already root,
# e.g. inside a container; through sudo otherwise).
as_root() {
    if [[ "$(id -u)" == 0 ]]; then
        run_cmd "$@"
    else
        run_cmd sudo "$@"
    fi
}

# write_root_file <path> <content>: writes a root-owned file.
write_root_file() {
    local path="$1" content="$2"
    if [[ "$DRY_RUN" == 1 ]]; then
        info "[dry-run] write $path"
        return 0
    fi
    printf '%s\n' "$content" | as_root tee "$path" >/dev/null
}

# install_key <url> <dest>: downloads a repository signing key (dearmored).
install_key() {
    local url="$1" dest="$2"
    if [[ "$DRY_RUN" == 1 ]]; then
        info "[dry-run] key $url -> $dest"
        return 0
    fi
    as_root install -d -m 0755 "$(dirname "$dest")"
    curl -fsSL "$url" | gpg --dearmor | as_root tee "$dest" >/dev/null
}

# install_with_script <name> <url> [args...]: runs a remote installer script.
install_with_script() {
    local name="$1" url="$2"
    shift 2
    if [[ "$DRY_RUN" == 1 ]]; then
        info "[dry-run] curl -fsSL $url | bash -s -- $*"
        return 0
    fi
    log "Installing $name..."
    curl -fsSL "$url" | bash -s -- "$@"
}

# --- Install state (used by `dotfiles rescue` / `dotfiles uninstall`) --------
DOTFILES_STATE="${DOTFILES_STATE:-$HOME/.local/state/dotfiles}"

# state_add <file> <line>: appends <line> to a state file once.
state_add() {
    [[ "$DRY_RUN" == 1 ]] && return 0
    mkdir -p "$DOTFILES_STATE"
    grep -qxF "$2" "$DOTFILES_STATE/$1" 2>/dev/null || printf '%s\n' "$2" >> "$DOTFILES_STATE/$1"
}

# install_file <src> <dest>: copies a file (for apps that rewrite their config
# and would replace a symlink). Backs up a different existing file first.
install_file() {
    local src="$1" dest="$2"
    if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
        info "ok (up to date): $dest"
        return 0
    fi
    run_cmd mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" || -L "$dest" ]]; then
        local backup
        backup="${dest}.bak-$(date +%Y%m%d%H%M%S)"
        warn "Backing up $dest -> $backup"
        run_cmd mv "$dest" "$backup"
    fi
    run_cmd cp "$src" "$dest"
    state_add files "$dest"
    [[ "$DRY_RUN" == 1 ]] || ok "  installed: $dest"
}
