#!/usr/bin/env bash
# lib/linux-common.sh — logic shared between Ubuntu and Fedora:
# dotfile linking, default shell, plugins, fonts and the window manager.
# Meant to be sourced from lib/ubuntu.sh and lib/fedora.sh.

NERD_FONT_VERSION="v3.2.1"

# read_pkgs <file>: prints the packages (ignoring comments and blank lines).
read_pkgs() {
    grep -vE '^\s*(#|$)' "$1" | tr '\n' ' '
}

# --- Terminal --------------------------------------------------------------

linux_set_default_shell() {
    local zsh_path
    zsh_path="$(command -v zsh || true)"
    if [[ -z "$zsh_path" ]]; then
        warn "zsh not found yet; skipping shell change."
        return 0
    fi
    if [[ "$SHELL" != "$zsh_path" ]]; then
        log "Setting zsh as the default shell..."
        chsh -s "$zsh_path" || warn "Could not change the shell (do it manually: chsh -s $zsh_path)."
    fi
}

linux_clone_p10k() {
    if [[ ! -d "$HOME/powerlevel10k" ]]; then
        log "Cloning Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
    else
        info "Powerlevel10k is already cloned."
    fi
}

linux_link_terminal() {
    log "Linking terminal configuration..."
    link_file "$DOTFILES_DIR/shell/.zshrc"            "$HOME/.zshrc"
    link_file "$DOTFILES_DIR/shell/.p10k.zsh"         "$HOME/.p10k.zsh"
    link_file "$DOTFILES_DIR/shell/zshrc.linux.sh"    "$HOME/.config/zsh/zshrc.linux.sh"
    # zsh plugins vendored in the repo (no sudo, in the user's home).
    link_file "$DOTFILES_DIR/shell/plugins" "$HOME/.local/share/zsh-plugins"
}

linux_install_nerd_font() {
    local font_dir="$HOME/.local/share/fonts"
    if fc-list 2>/dev/null | grep -qi "Hack Nerd Font"; then
        info "Hack Nerd Font already installed."
        return 0
    fi
    log "Installing Hack Nerd Font (${NERD_FONT_VERSION})..."
    mkdir -p "$font_dir"
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/Hack.zip"
    local tmp
    tmp="$(mktemp -d)"
    if wget -q "$url" -O "$tmp/Hack.zip"; then
        unzip -n -q "$tmp/Hack.zip" -d "$font_dir"
        fc-cache -f >/dev/null 2>&1 || true
        ok "Hack Nerd Font installed."
    else
        warn "Could not download the font; install it manually from nerd-fonts."
    fi
    rm -rf "$tmp"
}

linux_install_ai_clis() {
    if ! has_cmd claude; then
        log "Installing Claude Code CLI..."
        curl -fsSL https://claude.ai/install.sh | sh || warn "Failed to install claude; install it manually."
    else
        info "Claude CLI already installed."
    fi
    if ! has_cmd opencode; then
        log "Installing opencode..."
        curl -fsSL https://opencode.ai/install | bash || warn "Failed to install opencode; install it manually."
    else
        info "opencode already installed."
    fi
}

linux_configure_terminal() {
    linux_set_default_shell
    linux_clone_p10k
    linux_link_terminal
    linux_install_nerd_font
    linux_install_ai_clis
}

# --- Window manager (i3 + polybar) -----------------------------------------

linux_link_wm() {
    log "Linking i3 and polybar configuration..."
    link_file "$DOTFILES_DIR/wm/linux/i3/config"        "$HOME/.config/i3/config"
    link_file "$DOTFILES_DIR/wm/linux/i3/scripts"       "$HOME/.config/i3/scripts"
    link_file "$DOTFILES_DIR/wm/linux/i3/.screenlayout" "$HOME/.screenlayout"
    link_file "$DOTFILES_DIR/wm/linux/polybar"          "$HOME/.config/polybar"
    link_file "$DOTFILES_DIR/images/candado.png"        "$HOME/Pictures/candado.png"
}

linux_configure_wm() {
    linux_link_wm
    ok "i3/polybar linked. Network interface and battery detection is done by polybar/launch.sh at startup."
}
