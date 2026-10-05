#!/usr/bin/env bash
# lib/ubuntu.sh — package installation for Ubuntu/Debian (apt).
# Sourced from install.sh; reuses lib/linux-common.sh.

# shellcheck source=lib/linux-common.sh
. "$DOTFILES_DIR/lib/linux-common.sh"

pkg_refresh() {
    log "Refreshing package index (apt)..."
    as_root apt-get update -y
}

pkg_install() {
    as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

# apt_repo <name> <key-url> <deb-line-without-signed-by>
apt_repo() {
    local name="$1" key_url="$2" line="$3" keyring="/etc/apt/keyrings/$1.gpg"
    [[ -f "/etc/apt/sources.list.d/$name.list" ]] && return 0
    install_key "$key_url" "$keyring"
    write_root_file "/etc/apt/sources.list.d/$name.list" "deb [arch=${DEB_ARCH} signed-by=${keyring}] $line"
    pkg_refresh
}

component_terminal() {
    log "Installing terminal packages..."
    pkg_install ca-certificates curl gpg
    linux_install_list "$DOTFILES_DIR/packages/apt-terminal.txt"
    apt_repo warpdotdev https://releases.warp.dev/linux/keys/warp.asc \
        "https://releases.warp.dev/linux/deb stable main"
    pkg_install warp-terminal || warn "Could not install Warp."
    linux_configure_terminal
}

component_apps() {
    log "Installing apps (VS Code, Brave)..."
    pkg_install ca-certificates curl gpg
    apt_repo vscode https://packages.microsoft.com/keys/microsoft.asc \
        "https://packages.microsoft.com/repos/code stable main"
    apt_repo brave-browser https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
        "https://brave-browser-apt-release.s3.brave.com/ stable main"
    pkg_install code || warn "Could not install VS Code."
    pkg_install brave-browser || warn "Could not install Brave."
}

component_wm() {
    log "Installing window manager packages..."
    linux_install_list "$DOTFILES_DIR/packages/apt-wm.txt"
    linux_configure_wm
}
