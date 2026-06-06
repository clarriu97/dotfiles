#!/usr/bin/env bash
# lib/macos.sh — install and configure on macOS (Homebrew + AeroSpace + SketchyBar).
# Sourced from install.sh.

# --- Homebrew --------------------------------------------------------------
macos_install_homebrew() {
    if has_cmd brew; then
        info "Homebrew already installed."
    else
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # Load brew into this session's PATH (Apple Silicon or Intel).
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

macos_brew_bundle() {
    log "Installing packages with brew bundle..."
    brew bundle --file="$DOTFILES_DIR/packages/Brewfile" || \
        warn "A package in the Brewfile failed; check the output."
}

macos_install_ai_clis() {
    # opencode is installed via the Brewfile. Claude Code: official installer if missing.
    if ! has_cmd claude; then
        log "Installing Claude Code CLI..."
        curl -fsSL https://claude.ai/install.sh | sh || warn "Failed to install claude; install it manually."
    else
        info "Claude CLI already installed."
    fi
}

# --- Terminal --------------------------------------------------------------
macos_link_terminal() {
    log "Linking terminal configuration..."
    link_file "$DOTFILES_DIR/shell/.zshrc"         "$HOME/.zshrc"
    link_file "$DOTFILES_DIR/shell/.p10k.zsh"      "$HOME/.p10k.zsh"
    link_file "$DOTFILES_DIR/shell/zshrc.macos.sh" "$HOME/.config/zsh/zshrc.macos.sh"
}

macos_set_default_shell() {
    local zsh_path="/bin/zsh"
    has_cmd brew && [[ -x "$(brew --prefix)/bin/zsh" ]] && zsh_path="$(brew --prefix)/bin/zsh"
    if [[ "$SHELL" != "$zsh_path" ]]; then
        log "Setting zsh as the default shell..."
        chsh -s "$zsh_path" || warn "Could not change the shell (do it manually: chsh -s $zsh_path)."
    fi
}

macos_configure_terminal() {
    macos_set_default_shell
    macos_link_terminal
    macos_install_ai_clis
    ok "Terminal configured. Select 'Hack Nerd Font' in Warp/VS Code."
}

# --- Window manager (AeroSpace + SketchyBar) -------------------------------
macos_link_wm() {
    log "Linking AeroSpace and SketchyBar..."
    link_file "$DOTFILES_DIR/wm/macos/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"
    link_file "$DOTFILES_DIR/wm/macos/sketchybar"                "$HOME/.config/sketchybar"
}

macos_configure_wm() {
    macos_link_wm
    if has_cmd brew; then
        log "Starting SketchyBar as a service..."
        brew services start sketchybar || warn "Could not start sketchybar; start it manually."
    fi
    warn "AeroSpace needs Accessibility permission: System Settings > Privacy & Security > Accessibility."
    warn "Open the AeroSpace app (or run 'open -a AeroSpace') and grant it permission."
}

# --- Dispatch --------------------------------------------------------------
install_main() {
    local option="$1"
    macos_install_homebrew
    macos_brew_bundle
    case "$option" in
        terminal) macos_configure_terminal ;;
        wm)       macos_configure_wm ;;
        both)     macos_configure_terminal && macos_configure_wm ;;
    esac
}
