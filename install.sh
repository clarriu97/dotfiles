#!/usr/bin/env bash
#
# install.sh — cross-platform dotfiles installer (macOS / Ubuntu / Fedora).
#
# Usage:
#   ./install.sh                          # interactive: auto-detects the OS and asks
#   ./install.sh --yes --only terminal    # unattended, selected components
#   ./install.sh --dry-run                # print every action, change nothing
#   ./install.sh --help
#
set -euo pipefail

# Repo root (this script's directory), resolved robustly. Works no matter
# where the repo is cloned — all symlinks are created relative to this path.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

# shellcheck source=lib/common.sh
. "$DOTFILES_DIR/lib/common.sh"
# shellcheck source=lib/detect.sh
. "$DOTFILES_DIR/lib/detect.sh"

components_for() {
    case "$1" in
        macos)         echo "terminal apps wm keyboard desktop claude" ;;
        ubuntu|fedora) echo "terminal apps wm claude" ;;
        *)             echo "" ;;
    esac
}

describe_component() {
    case "$1:$OS" in
        terminal:macos) echo "zsh + powerlevel10k + CLI tools + Warp & Ghostty" ;;
        terminal:*)     echo "zsh + powerlevel10k + CLI tools + Warp" ;;
        apps:*)         echo "VS Code, Brave$([[ $OS == macos ]] && echo ', Raycast')" ;;
        wm:macos)       echo "AeroSpace tiling window manager" ;;
        wm:*)           echo "i3 + polybar" ;;
        keyboard:*)     echo "Karabiner-Elements: Left Option as window-manager key" ;;
        desktop:*)      echo "Dock auto-hide, Finder extensions & path bar, fast key repeat" ;;
        claude:*)       echo "Claude Code CLI + Desktop + versioned config" ;;
    esac
}

usage() {
    cat <<EOF
install.sh — cross-platform dotfiles installer

  -y, --yes                    Do not ask anything (all components unless --only)
  -n, --dry-run                Print every action without changing anything
      --only <a,b,...>         Components: terminal, apps, wm, keyboard (macOS), desktop (macOS), claude
      --os <macos|ubuntu|fedora>
                               Force the OS instead of auto-detecting
  -h, --help                   Show this help
EOF
}

# --- Argument parsing -------------------------------------------------------
FORCE_OS=""
ONLY=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes) ASSUME_YES=1; shift ;;
        -n|--dry-run) DRY_RUN=1; shift ;;
        --only) ONLY="${2:-}"; shift 2 ;;
        --only=*) ONLY="${1#*=}"; shift ;;
        --os) FORCE_OS="${2:-}"; shift 2 ;;
        --os=*) FORCE_OS="${1#*=}"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) err "Unknown option: $1"; usage; exit 2 ;;
    esac
done
export ASSUME_YES DRY_RUN
[[ -n "$FORCE_OS" ]] && OS="$FORCE_OS"

# --- OS validation ----------------------------------------------------------
AVAILABLE="$(components_for "$OS")"
if [[ -z "$AVAILABLE" ]]; then
    err "Unsupported or undetected OS: '${OS}' (raw: '${OS_RAW:-?}', arch: '${ARCH}')."
    err "Use --os macos|ubuntu|fedora to force it."
    exit 1
fi

# --- Component selection ----------------------------------------------------
SELECTED=""
if [[ -n "$ONLY" ]]; then
    for c in ${ONLY//,/ }; do
        if [[ " $AVAILABLE " != *" $c "* ]]; then
            err "Unknown component '$c' for $OS. Available: $AVAILABLE"
            exit 2
        fi
        SELECTED="$SELECTED $c"
    done
elif [[ "$ASSUME_YES" == 1 ]]; then
    SELECTED="$AVAILABLE"
fi

# --- Header ----------------------------------------------------------------
os_label() {
    case "$OS" in
        macos) echo "macOS $(sw_vers -productVersion 2>/dev/null)" ;;
        *)     echo "${OS_RAW} $(sed -n 's/^VERSION_ID="\{0,1\}\([^"]*\)"\{0,1\}$/\1/p' "$OS_RELEASE_FILE" 2>/dev/null)" ;;
    esac
}

echo -e "
${bold}${blue}  ╭───────────────────────────────────────────╮${nc}
${bold}${blue}  │${nc}  ${bold}dotfiles${nc} ${dim}· clarriu97/dotfiles${nc}              ${bold}${blue}│${nc}
${bold}${blue}  ╰───────────────────────────────────────────╯${nc}
${dim}  $(os_label) · ${ARCH}$([[ "$DRY_RUN" == 1 ]] && echo ' · dry run: nothing will change')${nc}"

# --- Interactive menu -------------------------------------------------------
if [[ -z "$SELECTED" ]]; then
    echo -e "\n${bold}  What should be installed?${nc}"
    i=1
    for c in $AVAILABLE; do
        printf "  ${green}%s${nc}  %-9s ${dim}%s${nc}\n" "$i" "$c" "$(describe_component "$c")"
        i=$((i + 1))
    done
    echo -ne "\n  Numbers separated by spaces, ${bold}Enter${nc} for everything: "
    read -r input
    if [[ -z "$input" ]]; then
        SELECTED="$AVAILABLE"
    else
        for n in $input; do
            c="$(echo "$AVAILABLE" | awk -v n="$n" '{ print $n }')"
            if [[ ! "$n" =~ ^[0-9]+$ || -z "$c" ]]; then
                err "Invalid option: $n"
                exit 2
            fi
            SELECTED="$SELECTED $c"
        done
    fi
fi
SELECTED="${SELECTED# }"

echo -e "\n  Components: ${bold}${green}${SELECTED}${nc}"
if ! ask_yes_no "  Install packages and link the configuration?"; then
    err "Cancelled."
    exit 1
fi

# --- Dispatch to the OS module ---------------------------------------------
# shellcheck source=/dev/null
. "$DOTFILES_DIR/lib/${OS}.sh"
# shellcheck source=lib/claude.sh
. "$DOTFILES_DIR/lib/claude.sh"
# shellcheck disable=SC2086
set -- $SELECTED
STEPS=$#
install_main "$@"
link_file "$DOTFILES_DIR/bin/dotfiles" "$HOME/.local/bin/dotfiles"

summary
echo -e "\n${bold}${green}  Done.${nc} Open a new terminal to load the configuration.\n"
