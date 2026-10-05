#!/usr/bin/env bash
# lib/fedora.sh — package installation for Fedora/RHEL (dnf).
# Sourced from install.sh; reuses lib/linux-common.sh.

# shellcheck source=lib/linux-common.sh
. "$DOTFILES_DIR/lib/linux-common.sh"

pkg_refresh() {
    log "Refreshing package metadata (dnf)..."
    as_root dnf makecache -y
}

pkg_install() {
    as_root dnf install -y "$@"
}

# dnf_repo <name> <key-url> <baseurl>
dnf_repo() {
    local name="$1" key_url="$2" baseurl="$3"
    [[ -f "/etc/yum.repos.d/$name.repo" ]] && return 0
    write_root_file "/etc/yum.repos.d/$name.repo" "[$name]
name=$name
baseurl=$baseurl
enabled=1
gpgcheck=1
gpgkey=$key_url"
}

component_terminal() {
    log "Installing terminal packages..."
    linux_install_list "$DOTFILES_DIR/packages/dnf-terminal.txt"
    dnf_repo warpdotdev https://releases.warp.dev/linux/keys/warp.asc \
        https://releases.warp.dev/linux/rpm/stable
    pkg_install warp-terminal || warn "Could not install Warp."
    linux_configure_terminal
}

component_apps() {
    log "Installing apps (VS Code, Brave)..."
    dnf_repo vscode https://packages.microsoft.com/keys/microsoft.asc \
        https://packages.microsoft.com/yumrepos/vscode
    dnf_repo brave-browser https://brave-browser-rpm-release.s3.brave.com/brave-core.asc \
        https://brave-browser-rpm-release.s3.brave.com/"$(uname -m)"
    pkg_install code || warn "Could not install VS Code."
    pkg_install brave-browser || warn "Could not install Brave."
}

component_wm() {
    log "Installing window manager packages..."
    linux_install_list "$DOTFILES_DIR/packages/dnf-wm.txt"
    linux_configure_wm
}
