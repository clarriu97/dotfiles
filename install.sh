#!/usr/bin/env bash
#
# install.sh — cross-platform dotfiles installer (macOS / Ubuntu / Fedora).
#
# Usage:
#   ./install.sh                 # auto-detects the OS
#   ./install.sh --os macos      # force a specific OS (macos|ubuntu|fedora)
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

usage() {
    cat <<EOF
install.sh — cross-platform dotfiles installer

  --os <macos|ubuntu|fedora>   Force the OS instead of auto-detecting
  -h, --help                   Show this help
EOF
}

# --- Argument parsing -------------------------------------------------------
FORCE_OS=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --os) FORCE_OS="${2:-}"; shift 2 ;;
        --os=*) FORCE_OS="${1#*=}"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) err "Unknown option: $1"; usage; exit 1 ;;
    esac
done
[[ -n "$FORCE_OS" ]] && OS="$FORCE_OS"

# --- Banner -----------------------------------------------------------------
echo -e "${orange}"
echo -e "██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗    ████████╗ ██████╗ "
echo -e "██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝    ╚══██╔══╝██╔═══██╗"
echo -e "██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗         ██║   ██║   ██║"
echo -e "██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝         ██║   ██║   ██║"
echo -e "╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗       ██║   ╚██████╔╝"
echo -e " ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝       ╚═╝    ╚═════╝ "
echo -e "          ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗             "
echo -e "          ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝             "
echo -e "          ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗             "
echo -e "          ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║             "
echo -e "          ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║             "
echo -e "          ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝             "
echo -e "${nc}"
echo -e "A project by ${red}clarriu97${nc} — https://github.com/${red}clarriu97${nc}/dotfiles"

# --- OS validation ----------------------------------------------------------
if [[ "$OS" != "macos" && "$OS" != "ubuntu" && "$OS" != "fedora" ]]; then
    err "Unsupported or undetected OS: '${OS}' (raw: '${OS_RAW:-?}', arch: '${ARCH}')."
    err "Use --os macos|ubuntu|fedora to force it."
    exit 1
fi
log "\nDetected system: ${green}${OS}${orange} (${ARCH})"

# --- Confirmation -----------------------------------------------------------
if ! ask_yes_no "This script will install packages and link your configuration. Continue?"; then
    err "Cancelled."
    exit 1
fi

# --- Options menu -----------------------------------------------------------
echo -e "\n${white}What do you want to install and configure?${nc}"
echo -e "${green}1) Terminal${nc} (zsh + powerlevel10k + CLI tools)"
echo -e "${green}2) Window manager${nc} ($([[ $OS == macos ]] && echo 'AeroSpace + SketchyBar' || echo 'i3 + polybar'))"
echo -e "${green}3) Both${nc}"
read -r input
case "${input:-1}" in
    1) option="terminal" ;;
    2) option="wm" ;;
    3) option="both" ;;
    *) err "Invalid option."; exit 1 ;;
esac

# --- Dispatch to the OS module ---------------------------------------------
# shellcheck source=/dev/null
. "$DOTFILES_DIR/lib/${OS}.sh"
install_main "$option"

ok "\nDone! Open a new terminal to load the configuration."
log "Thanks for using this script."
