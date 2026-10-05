#!/usr/bin/env bash
# lib/linux-common.sh — logic shared between Ubuntu and Fedora:
# dotfile linking, default shell, plugins, fonts and the window manager.
# Expects the distro module to define pkg_install <pkgs...>.

NERD_FONT_VERSION="v3.2.1"

# linux_install_list <file>: installs a package list in one go; if that fails,
# retries one by one so a single missing package does not block the rest.
linux_install_list() {
    local file="$1" pkgs p failed=""
    pkgs="$(read_pkgs "$file")"
    # shellcheck disable=SC2086
    pkg_install $pkgs && return 0
    warn "Bulk install failed; retrying package by package..."
    for p in $pkgs; do
        pkg_install "$p" || failed="$failed $p"
    done
    [[ -n "$failed" ]] && warn "Packages not installed:$failed"
    return 0
}

# --- Terminal --------------------------------------------------------------

linux_set_default_shell() {
    local zsh_path user
    zsh_path="$(command -v zsh || true)"
    user="$(id -un)"
    if [[ -z "$zsh_path" ]]; then
        warn "zsh not found; skipping shell change."
        return 0
    fi
    if [[ "$(getent passwd "$user" | cut -d: -f7)" != "$zsh_path" ]]; then
        log "Setting zsh as the default shell..."
        as_root chsh -s "$zsh_path" "$user" || warn "Could not change the shell (do it manually: chsh -s $zsh_path)."
    fi
}

linux_clone_p10k() {
    if [[ ! -d "$HOME/powerlevel10k" ]]; then
        log "Cloning Powerlevel10k..."
        run_cmd git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
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
    if [[ "$DRY_RUN" == 1 ]]; then
        info "[dry-run] install Hack Nerd Font ${NERD_FONT_VERSION} into $font_dir"
        return 0
    fi
    log "Installing Hack Nerd Font (${NERD_FONT_VERSION})..."
    mkdir -p "$font_dir"
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/Hack.zip"
    local tmp
    tmp="$(mktemp -d)"
    if curl -fsSL "$url" -o "$tmp/Hack.zip"; then
        unzip -n -q "$tmp/Hack.zip" -d "$font_dir"
        fc-cache -f >/dev/null 2>&1 || true
        ok "Hack Nerd Font installed."
    else
        warn "Could not download the font; install it manually from nerd-fonts."
    fi
    rm -rf "$tmp"
}

linux_install_opencode() {
    if has_cmd opencode || [[ -x "$HOME/.opencode/bin/opencode" ]]; then
        info "opencode already installed."
    else
        install_with_script opencode https://opencode.ai/install || warn "Failed to install opencode."
    fi
}

linux_configure_terminal() {
    linux_set_default_shell
    linux_clone_p10k
    linux_link_terminal
    linux_install_nerd_font
    linux_install_opencode
}

# --- Window manager (i3 + polybar) -----------------------------------------

linux_configure_wm() {
    log "Linking i3 and polybar configuration..."
    link_file "$DOTFILES_DIR/wm/linux/i3/config"        "$HOME/.config/i3/config"
    link_file "$DOTFILES_DIR/wm/linux/i3/scripts"       "$HOME/.config/i3/scripts"
    link_file "$DOTFILES_DIR/wm/linux/i3/.screenlayout" "$HOME/.screenlayout"
    link_file "$DOTFILES_DIR/wm/linux/polybar"          "$HOME/.config/polybar"
    link_file "$DOTFILES_DIR/images/candado.png"        "$HOME/Pictures/candado.png"
}

# --- Dispatch --------------------------------------------------------------

install_main() {
    local c
    pkg_refresh
    for c in "$@"; do
        "component_$c"
    done
}
