#!/usr/bin/env bash
# lib/fedora.sh — package installation for Fedora/RHEL (dnf).
# Sourced from install.sh; reuses lib/linux-common.sh.

# shellcheck source=lib/linux-common.sh
. "$DOTFILES_DIR/lib/linux-common.sh"

fedora_update() {
    log "Updating the system (dnf)..."
    sudo dnf upgrade -y
}

fedora_install_extra_repos() {
    log "Configuring external repos (VS Code, Brave, Warp)..."

    # VS Code
    if ! has_cmd code; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    fi

    # Brave
    if ! has_cmd brave-browser; then
        sudo dnf install -y dnf-plugins-core
        sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc || true
    fi

    # Warp
    if ! has_cmd warp-terminal; then
        sudo rpm --import https://releases.warp.dev/linux/keys/warp.asc
        sudo sh -c 'echo -e "[warpdotdev]\nname=warpdotdev\nbaseurl=https://releases.warp.dev/linux/rpm/stable\nenabled=1\ngpgcheck=1\ngpgkey=https://releases.warp.dev/linux/keys/warp.asc" > /etc/yum.repos.d/warpdotdev.repo'
    fi

    sudo dnf install -y code brave-browser warp-terminal || \
        warn "An external-repo package failed; check the output."
}

fedora_install_base() {
    log "Installing base packages (terminal)..."
    # shellcheck disable=SC2046
    sudo dnf install -y $(read_pkgs "$DOTFILES_DIR/packages/dnf-base.txt")
    fedora_install_extra_repos
}

fedora_install_wm() {
    log "Installing window manager packages..."
    # shellcheck disable=SC2046
    sudo dnf install -y $(read_pkgs "$DOTFILES_DIR/packages/dnf-wm.txt")
}

install_main() {
    local option="$1"
    fedora_update
    case "$option" in
        terminal) fedora_install_base && linux_configure_terminal ;;
        wm)       fedora_install_wm   && linux_configure_wm ;;
        both)     fedora_install_base && fedora_install_wm \
                      && linux_configure_terminal && linux_configure_wm ;;
    esac
}
