#!/usr/bin/env bash
# lib/rescue.sh — `dotfiles rescue` and `dotfiles uninstall`.
# Sourced by bin/dotfiles after lib/common.sh and lib/detect.sh.

KARABINER_CLI="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

rescue_aerospace() {
    [[ -d /Applications/AeroSpace.app ]] || return 0
    log "AeroSpace: switching to the rescue config (no keys, no start at login) and quitting..."
    if [[ -L "$HOME/.aerospace.toml" ]]; then
        run_cmd rm "$HOME/.aerospace.toml"
    elif [[ -e "$HOME/.aerospace.toml" ]]; then
        run_cmd mv "$HOME/.aerospace.toml" "$HOME/.aerospace.toml.bak-$(date +%Y%m%d%H%M%S)"
    fi
    run_cmd cp "$DOTFILES_DIR/wm/macos/aerospace/rescue.toml" "$HOME/.aerospace.toml"
    if pgrep -x AeroSpace >/dev/null; then
        run_cmd aerospace reload-config >/dev/null 2>&1 || true
        run_cmd osascript -e 'quit app "AeroSpace"' >/dev/null 2>&1 || run_cmd pkill -x AeroSpace || true
    fi
    run_cmd pkill -x borders || true
}

rescue_karabiner() {
    [[ -x "$KARABINER_CLI" ]] || return 0
    log "Karabiner: selecting the empty 'Plain' profile (keyboard back to stock)..."
    run_cmd "$KARABINER_CLI" --select-profile Plain || warn "Could not switch the Karabiner profile."
}

rescue_main() {
    if [[ "$OS" != macos ]]; then
        info "Nothing to rescue on $OS: the Linux setup changes no system behaviour."
        return 0
    fi
    rescue_aerospace
    rescue_karabiner
    log "Restoring every macOS setting changed by the installer..."
    macos_restore_defaults
    run_cmd /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
    run_cmd killall Dock Finder >/dev/null 2>&1 || true
    run_cmd killall SystemUIServer >/dev/null 2>&1 || true
    ok "Rescued: stock keyboard, windows back on screen, original macOS settings."
    info "Re-enable later with: ./install.sh --only wm,keyboard"
}

# restore_latest_backup <dest>: moves the newest <dest>.bak-* back into place.
restore_latest_backup() {
    local dest="$1" backup
    backup="$(find "$(dirname "$dest")" -maxdepth 1 -name "$(basename "$dest").bak-*" 2>/dev/null | sort | tail -1)"
    if [[ -n "$backup" ]]; then
        run_cmd mv "$backup" "$dest"
        info "restored: $dest"
    fi
}

uninstall_main() {
    local dest
    rescue_main
    log "Removing links into $DOTFILES_DIR and restoring the previous files..."
    if [[ -f "$DOTFILES_STATE/links" ]]; then
        while read -r dest; do
            if [[ -L "$dest" && "$(readlink "$dest")" == "$DOTFILES_DIR"/* ]]; then
                run_cmd rm "$dest"
                restore_latest_backup "$dest"
            fi
        done < "$DOTFILES_STATE/links"
    fi
    if [[ -f "$DOTFILES_STATE/files" ]]; then
        while read -r dest; do
            [[ "$dest" == */LaunchAgents/*.plist ]] && run_cmd launchctl bootout "gui/$(id -u)" "$dest" 2>/dev/null
            [[ -f "$dest" ]] && run_cmd rm "$dest"
            restore_latest_backup "$dest"
        done < "$DOTFILES_STATE/files"
    fi
    [[ "$DRY_RUN" == 1 ]] || rm -f "$DOTFILES_STATE/links" "$DOTFILES_STATE/files"
    ok "Uninstalled. Installed apps and packages were kept."
    [[ "$OS" == macos ]] && info "Remove apps with: brew uninstall --cask aerospace karabiner-elements"
    return 0
}
