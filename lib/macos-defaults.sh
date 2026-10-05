#!/usr/bin/env bash
# lib/macos-defaults.sh — `defaults write` that remembers the previous value of
# every key it changes, so `dotfiles rescue` can put each one back exactly.
# Backups: $DOTFILES_STATE/defaults.d/<domain>@<key>.plist ("absent" if unset).

defaults_backup_path() { echo "$DOTFILES_STATE/defaults.d/$1@$2.plist"; }

# macos_default <domain> <key> <defaults-write args...>
#   macos_default com.apple.dock autohide -bool true
macos_default() {
    local domain="$1" key="$2" backup
    shift 2
    backup="$(defaults_backup_path "$domain" "$key")"
    if [[ "$DRY_RUN" == 1 ]]; then
        info "[dry-run] defaults write $domain $key $*"
        return 0
    fi
    if [[ ! -e "$backup" ]]; then
        mkdir -p "$(dirname "$backup")"
        defaults export "$domain" - 2>/dev/null | plutil -extract "$key" xml1 -o "$backup" - 2>/dev/null ||
            echo absent > "$backup"
        state_add defaults "$domain@$key"
    fi
    defaults write "$domain" "$key" "$@"
}

# macos_restore_defaults: puts back every key changed by macos_default.
macos_restore_defaults() {
    local entry domain key backup value
    [[ -f "$DOTFILES_STATE/defaults" ]] || return 0
    while read -r entry; do
        domain="${entry%@*}"
        key="${entry##*@}"
        backup="$(defaults_backup_path "$domain" "$key")"
        [[ -f "$backup" ]] || continue
        if [[ "$(cat "$backup")" == absent ]]; then
            run_cmd defaults delete "$domain" "$key" 2>/dev/null || true
        else
            value="$(sed -e '1,/<plist/d' -e '/<\/plist>/,$d' "$backup")"
            run_cmd defaults write "$domain" "$key" "$value"
        fi
        info "restored: $domain $key"
    done < "$DOTFILES_STATE/defaults"
    [[ "$DRY_RUN" == 1 ]] && return 0
    rm -rf "$DOTFILES_STATE/defaults" "$DOTFILES_STATE/defaults.d"
}
