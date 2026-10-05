#!/usr/bin/env bash
# lib/claude.sh — Claude Code CLI + Desktop + versioned configuration.
# Sourced by the OS modules; uses pkg_install on Linux and Homebrew on macOS.

CLAUDE_BIN="$HOME/.local/bin/claude"
CLAUDE_MARKETPLACE="anthropics/claude-plugins-official"

claude_install_cli() {
    if [[ -x "$CLAUDE_BIN" ]]; then
        info "Claude Code CLI (native) already installed."
    else
        install_with_script "Claude Code CLI" https://claude.ai/install.sh
    fi
    if [[ "$OS" == macos && -d "${HOMEBREW_PREFIX:-/opt/homebrew}/Caskroom/claude-code" ]]; then
        log "Removing the duplicate Homebrew claude-code cask (the native install auto-updates)..."
        run_cmd brew uninstall --cask claude-code
    fi
}

claude_install_desktop() {
    case "$OS" in
        macos)
            if [[ -d /Applications/Claude.app ]]; then
                info "Claude Desktop already installed."
            else
                run_cmd brew install --cask claude || warn "Could not install Claude Desktop."
            fi
            ;;
        ubuntu)
            if has_cmd claude-desktop; then
                info "Claude Desktop already installed."
                return 0
            fi
            log "Installing Claude Desktop (beta) from Anthropic's apt repository..."
            as_root install -d -m 0755 /usr/share/keyrings
            as_root curl -fsSLo /usr/share/keyrings/claude-desktop-archive-keyring.asc \
                https://downloads.claude.ai/claude-desktop/key.asc
            write_root_file /etc/apt/sources.list.d/claude-desktop.list \
                "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/claude-desktop-archive-keyring.asc] https://downloads.claude.ai/claude-desktop/apt/stable stable main"
            pkg_refresh
            pkg_install claude-desktop || warn "Could not install Claude Desktop."
            ;;
        *)
            info "Claude Desktop has no official build for $OS_RAW yet; the CLI covers it."
            ;;
    esac
}

claude_ensure_jq() {
    has_cmd jq && return 0
    if [[ "$OS" == macos ]]; then
        run_cmd brew install jq
    else
        pkg_install jq
    fi
}

claude_link_config() {
    local skill
    log "Linking Claude Code configuration..."
    link_file "$DOTFILES_DIR/claude/CLAUDE.md"     "$HOME/.claude/CLAUDE.md"
    link_file "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
    link_file "$DOTFILES_DIR/claude/statusline.sh" "$HOME/.claude/statusline.sh"
    link_file "$DOTFILES_DIR/claude/hooks"         "$HOME/.claude/hooks"
    for skill in "$DOTFILES_DIR"/claude/skills/*/; do
        skill="${skill%/}"
        link_file "$skill" "$HOME/.claude/skills/${skill##*/}"
    done
}

claude_install_plugins() {
    local plugin
    if [[ "$DRY_RUN" == 1 ]]; then
        info "[dry-run] claude plugin install <enabledPlugins from claude/settings.json>"
        return 0
    fi
    log "Installing Claude Code plugins..."
    "$CLAUDE_BIN" plugin marketplace add "$CLAUDE_MARKETPLACE" >/dev/null ||
        warn "Could not add the $CLAUDE_MARKETPLACE marketplace."
    jq -r '.enabledPlugins // {} | to_entries[] | select(.value == true) | .key' \
        "$DOTFILES_DIR/claude/settings.json" | while read -r plugin; do
        "$CLAUDE_BIN" plugin install "$plugin" --scope user </dev/null ||
            warn "Could not install plugin $plugin."
    done
}

component_claude() {
    claude_install_cli
    claude_install_desktop
    claude_ensure_jq
    claude_link_config
    claude_install_plugins
    ok "Claude Code ready. Run 'claude' once to sign in."
}
