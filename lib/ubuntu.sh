#!/usr/bin/env bash
# lib/ubuntu.sh — package installation for Ubuntu/Debian (apt).
# Sourced from install.sh; reuses lib/linux-common.sh.

# shellcheck source=lib/linux-common.sh
. "$DOTFILES_DIR/lib/linux-common.sh"

ubuntu_update() {
    log "Updating the system (apt)..."
    sudo apt-get update -y && sudo apt-get upgrade -y
}

# External repos + packages not available in the default repos.
ubuntu_install_extra_repos() {
    log "Configuring external repos (VS Code, Brave, Warp)..."
    sudo apt-get install -y software-properties-common apt-transport-https wget gpg

    # VS Code
    if ! has_cmd code; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
            | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg >/dev/null
        echo "deb [arch=${DEB_ARCH} signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
            | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
    fi

    # Brave
    if ! has_cmd brave-browser; then
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
            https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
            | sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null
    fi

    # Warp
    if ! has_cmd warp-terminal; then
        wget -qO- https://releases.warp.dev/linux/keys/warp.asc \
            | gpg --dearmor | sudo tee /etc/apt/keyrings/warpdotdev.gpg >/dev/null
        echo "deb [arch=${DEB_ARCH} signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" \
            | sudo tee /etc/apt/sources.list.d/warpdotdev.list >/dev/null
    fi

    sudo apt-get update -y
    sudo apt-get install -y code brave-browser warp-terminal || \
        warn "An external-repo package failed; check the output."
}

ubuntu_install_base() {
    log "Installing base packages (terminal)..."
    # shellcheck disable=SC2046
    sudo apt-get install -y $(read_pkgs "$DOTFILES_DIR/packages/apt-base.txt")
    ubuntu_install_extra_repos
}

ubuntu_install_wm() {
    log "Installing window manager packages..."
    # shellcheck disable=SC2046
    sudo apt-get install -y $(read_pkgs "$DOTFILES_DIR/packages/apt-wm.txt")
}

install_main() {
    local option="$1"
    ubuntu_update
    case "$option" in
        terminal) ubuntu_install_base && linux_configure_terminal ;;
        wm)       ubuntu_install_wm   && linux_configure_wm ;;
        both)     ubuntu_install_base && ubuntu_install_wm \
                      && linux_configure_terminal && linux_configure_wm ;;
    esac
}
