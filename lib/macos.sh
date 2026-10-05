#!/usr/bin/env bash
# lib/macos.sh — install and configure on macOS (Homebrew + AeroSpace + Karabiner).
# Sourced from install.sh.

BREWFILES="$DOTFILES_DIR/packages/macos"

# shellcheck source=lib/macos-defaults.sh
. "$DOTFILES_DIR/lib/macos-defaults.sh"

# --- Homebrew --------------------------------------------------------------
macos_load_brew() {
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

macos_install_homebrew() {
    macos_load_brew
    if has_cmd brew; then
        info "Homebrew already installed."
        return 0
    fi
    if [[ "$DRY_RUN" == 1 ]]; then
        info "[dry-run] install Homebrew"
        return 0
    fi
    log "Installing Homebrew..."
    NONINTERACTIVE="$ASSUME_YES" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    macos_load_brew
}

# Homebrew 6.0+ refuses to install from third-party taps until they are trusted
# (supply-chain safeguard). No-op on older Homebrew.
macos_trust_taps() {
    local brewfile="$1" t
    if [[ "$DRY_RUN" != 1 ]]; then
        has_cmd brew || return 0
        brew trust --help >/dev/null 2>&1 || return 0
    fi
    sed -n 's/^tap "\([^"]*\)".*/\1/p' "$brewfile" | while read -r t; do
        run_cmd brew tap "$t"
        run_cmd brew trust "$t"
    done
}

# macos_bundle <component>: installs packages/macos/<component>.Brewfile.
macos_bundle() {
    local brewfile="$BREWFILES/$1.Brewfile"
    log "Installing $1 packages (brew bundle)..."
    macos_trust_taps "$brewfile"
    run_cmd brew bundle --no-upgrade --file="$brewfile" ||
        warn "Some $1 packages failed to install (see above); continuing. 'make doctor' reports what is missing."
}

# --- Terminal --------------------------------------------------------------
macos_set_default_shell() {
    if [[ "${SHELL:-}" != */zsh ]]; then
        log "Setting zsh as the default shell..."
        as_root chsh -s /bin/zsh "$(id -un)" || warn "Could not change the shell (do it manually: chsh -s /bin/zsh)."
    fi
}

component_terminal() {
    macos_bundle terminal
    macos_set_default_shell
    log "Linking terminal configuration..."
    link_file "$DOTFILES_DIR/shell/.zshrc"         "$HOME/.zshrc"
    link_file "$DOTFILES_DIR/shell/.p10k.zsh"      "$HOME/.p10k.zsh"
    link_file "$DOTFILES_DIR/shell/zshrc.macos.sh" "$HOME/.config/zsh/zshrc.macos.sh"
    ok "Terminal configured. Select 'Hack Nerd Font' in Warp/VS Code."
}

# --- Apps ------------------------------------------------------------------
component_apps() {
    macos_bundle apps
}

# --- Window manager (AeroSpace) --------------------------------------------
component_wm() {
    macos_bundle wm
    link_file "$DOTFILES_DIR/wm/macos/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"

    log "Mission Control settings recommended by AeroSpace (reverted by 'dotfiles rescue')..."
    macos_default com.apple.dock expose-group-apps -bool true
    macos_default com.apple.spaces spans-displays -bool true
    run_cmd killall Dock >/dev/null 2>&1 || true

    warn "AeroSpace is installed but NOT started. When you are ready:"
    warn "  1) open -a AeroSpace"
    warn "  2) System Settings > Privacy & Security > Accessibility > enable AeroSpace"
    warn "  Log out and back in once so 'Displays have separate Spaces' takes effect."
    warn "  Something wrong? Run: dotfiles rescue"
}

# --- Keyboard (Karabiner-Elements) -----------------------------------------
component_keyboard() {
    macos_bundle keyboard
    # Karabiner rewrites karabiner.json on every change, which would replace a symlink.
    install_file "$DOTFILES_DIR/wm/macos/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

    warn "Karabiner-Elements only acts after these one-time approvals:"
    warn "  System Settings > General > Login Items & Extensions > Driver Extensions > enable Karabiner"
    warn "  System Settings > Privacy & Security > Input Monitoring > enable karabiner_grabber / karabiner_observer"
    warn "  Input source: 'Spanish - ISO' (System Settings > Keyboard > Text Input)."
    warn "  Left Option + window-manager keys go to AeroSpace; Right Option keeps @ # | [ ] { } \\ ~."
    warn "  The Karabiner menu-bar icon switches to the 'Plain' profile at any time."
}

# --- Dispatch --------------------------------------------------------------
install_main() {
    local c
    macos_install_homebrew
    for c in "$@"; do
        "component_$c"
    done
}
