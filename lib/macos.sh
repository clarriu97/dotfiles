#!/usr/bin/env bash
# lib/macos.sh — install and configure on macOS (Homebrew + AeroSpace + Karabiner).
# Sourced from install.sh.

BREWFILES="$DOTFILES_DIR/packages/macos"

# shellcheck source=lib/macos-defaults.sh
. "$DOTFILES_DIR/lib/macos-defaults.sh"
# shellcheck source=lib/macos-permissions.sh
. "$DOTFILES_DIR/lib/macos-permissions.sh"

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
    local attempt
    for attempt in 1 2; do
        NONINTERACTIVE="$ASSUME_YES" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && break
        [[ "$attempt" == 2 ]] && { err "Homebrew could not be installed (see above)."; return 1; }
        warn "Homebrew install failed (Apple's Command Line Tools download is sometimes flaky); retrying once..."
    done
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
# --adopt takes over apps that were installed by hand (same version) instead of failing.
macos_bundle() {
    local brewfile="$BREWFILES/$1.Brewfile"
    log "Installing $1 packages (brew bundle)..."
    macos_trust_taps "$brewfile"
    HOMEBREW_CASK_OPTS="${HOMEBREW_CASK_OPTS:-} --adopt" run_cmd brew bundle --no-upgrade --file="$brewfile" ||
        HOMEBREW_CASK_OPTS="${HOMEBREW_CASK_OPTS:-} --adopt" run_cmd brew bundle --no-upgrade --file="$brewfile" ||
        warn "Some $1 packages failed to install (see above); continuing. 'make doctor' reports what is missing."
}

# --- Terminal --------------------------------------------------------------
macos_set_default_shell() {
    if [[ "${SHELL:-}" != */zsh ]]; then
        log "Setting zsh as the default shell..."
        as_root chsh -s /bin/zsh "$(id -un)" || warn "Could not change the shell (do it manually: chsh -s /bin/zsh)."
    fi
}

# Warp's cask often lags behind re-published downloads (checksum mismatch);
# fall back to the official DMG, installed only if Gatekeeper accepts it as notarized.
macos_ensure_warp() {
    local tmp mnt
    [[ -d /Applications/Warp.app ]] && return 0
    if [[ "$DRY_RUN" == 1 ]]; then
        info "[dry-run] download Warp from releases.warp.dev if the cask failed"
        return 0
    fi
    warn "Homebrew could not install Warp; downloading the official build..."
    tmp="$(mktemp -d)"
    if curl -fsSL -o "$tmp/Warp.dmg" 'https://app.warp.dev/download?package=dmg' &&
        mnt="$(hdiutil attach -nobrowse -readonly "$tmp/Warp.dmg" | tail -1 | cut -f3-)"; then
        if spctl -a -t exec -vv "$mnt/Warp.app" 2>&1 | grep -q 'source=Notarized Developer ID'; then
            cp -R "$mnt/Warp.app" /Applications/ && ok "Warp installed from releases.warp.dev."
        else
            warn "The downloaded Warp is not notarized; not installed."
        fi
        hdiutil detach -quiet "$mnt"
    else
        warn "Could not download Warp; install it from https://www.warp.dev"
    fi
    rm -rf "$tmp"
}

component_terminal() {
    macos_bundle terminal
    macos_ensure_warp
    macos_set_default_shell
    log "Linking terminal configuration..."
    link_file "$DOTFILES_DIR/shell/.zshrc"         "$HOME/.zshrc"
    link_file "$DOTFILES_DIR/shell/.p10k.zsh"      "$HOME/.p10k.zsh"
    link_file "$DOTFILES_DIR/shell/zshrc.macos.sh" "$HOME/.config/zsh/zshrc.macos.sh"
    link_file "$DOTFILES_DIR/terminal/ghostty/config" "$HOME/.config/ghostty/config"
    link_file "$DOTFILES_DIR/terminal/warp/themes/tokyo_night.yaml" "$HOME/.warp/themes/tokyo_night.yaml"
    macos_free_ctrl_arrows
    ok "Terminal configured. In Warp: Settings > Appearance > Theme 'Tokyo Night', font 'Hack Nerd Font'."
}

# Ctrl+Left/Right move between Spaces by default; free them so they jump words
# in the terminal like on Linux (AeroSpace workspaces replace Spaces).
macos_free_ctrl_arrows() {
    local id
    log "Freeing Ctrl+Left/Right from Mission Control (reverted by 'dotfiles rescue')..."
    for id in 79 80 81 82; do
        macos_default com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$id" '<dict><key>enabled</key><false/></dict>'
    done
    run_cmd /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
}

# --- Apps ------------------------------------------------------------------
component_apps() {
    local agent
    macos_bundle apps
    log "Starting Stats and Caffeine at login..."
    for agent in "$DOTFILES_DIR"/packages/macos/launchagents/*.plist; do
        install_file "$agent" "$HOME/Library/LaunchAgents/${agent##*/}"
        run_cmd launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/${agent##*/}" 2>/dev/null || true
    done
}

# --- Window manager (AeroSpace) --------------------------------------------
component_wm() {
    macos_bundle wm
    link_file "$DOTFILES_DIR/wm/macos/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"

    log "Mission Control settings recommended by AeroSpace (reverted by 'dotfiles rescue')..."
    if [[ "$(defaults read com.apple.spaces spans-displays 2>/dev/null)" != 1 ]]; then
        pending "Log out and back in once, so 'Displays have separate Spaces' (off) takes effect."
    fi
    macos_default com.apple.dock expose-group-apps -bool true
    macos_default com.apple.spaces spans-displays -bool true
    # AeroSpace's menu-bar label lists every occupied workspace (like i3bar).
    macos_default bobko.aerospace displayStyle -string i3Ordered
    run_cmd killall Dock >/dev/null 2>&1 || true

    macos_install_rescue_app
}

# --- Keyboard (Karabiner-Elements) -----------------------------------------
component_keyboard() {
    macos_bundle keyboard
    # Karabiner rewrites karabiner.json on every change, which would replace a symlink.
    install_file "$DOTFILES_DIR/wm/macos/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

    macos_install_rescue_app
}

# --- Desktop (Dock, Finder, keyboard) --------------------------------------
component_desktop() {
    log "Dock, Finder and key repeat (reverted by 'dotfiles rescue')..."
    macos_default com.apple.dock autohide -bool true
    macos_default com.apple.dock autohide-delay -float 0
    macos_default com.apple.dock show-recents -bool false
    macos_default com.apple.dock tilesize -int 48
    macos_default com.apple.finder ShowPathbar -bool true
    macos_default NSGlobalDomain AppleShowAllExtensions -bool true
    macos_default NSGlobalDomain KeyRepeat -int 2
    macos_default NSGlobalDomain InitialKeyRepeat -int 15
    run_cmd killall Dock Finder >/dev/null 2>&1 || true
    info "Key repeat applies after logging out and back in."
}

# --- Dispatch --------------------------------------------------------------
install_main() {
    local c guided=0
    case " $* " in *" wm "*|*" keyboard "*|*" apps "*) guided=1; STEPS=$((STEPS + 1)) ;; esac
    macos_install_homebrew
    for c in "$@"; do
        section "$c" "$(describe_component "$c")"
        "component_$c"
    done
    if [[ "$guided" == 1 ]]; then
        macos_guided_permissions "$@"
    fi
}
