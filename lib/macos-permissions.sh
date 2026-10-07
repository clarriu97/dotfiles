#!/usr/bin/env bash
# lib/macos-permissions.sh — walks the user through the approvals macOS does not
# allow scripts to grant: opens the right System Settings pane, says which
# switch to turn on, and waits until the approval is detected (Enter skips).
# With --yes or --dry-run nothing is opened; the steps go to the summary.
# shellcheck disable=SC2154

SETTINGS_PRIVACY_ACCESSIBILITY="x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
SETTINGS_LOGIN_ITEMS="x-apple.systempreferences:com.apple.LoginItems-Settings.extension"
SETTINGS_KEYBOARD="x-apple.systempreferences:com.apple.Keyboard-Settings.extension"

macos_major() { sw_vers -productVersion 2>/dev/null | cut -d. -f1; }

# macOS 27 renamed Privacy & Security > Accessibility.
accessibility_pane() {
    if [[ "$(macos_major)" -ge 27 ]]; then
        echo "Privacy & Security > Device Control and Data Access"
    else
        echo "Privacy & Security > Accessibility"
    fi
}

aerospace_trusted() { pgrep -x AeroSpace >/dev/null && aerospace list-workspaces --focused >/dev/null 2>&1; }
karabiner_daemon_running() { pgrep -u root -f Karabiner-Core-Service >/dev/null 2>&1; }
karabiner_driver_enabled() { systemextensionsctl list 2>/dev/null | grep -q 'Karabiner.*\[activated enabled\]'; }
spanish_iso_enabled() { defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null | grep -q 'Spanish - ISO'; }
needs_confirmation() { return 1; }
# Karabiner sends Left Option + d as Ctrl+Option+Shift+Cmd+D. Raycast ignores a
# hotkey written with defaults; it has to be recorded in its settings.
raycast_hotkey_set() { [[ "$(defaults read com.raycast.macos raycastGlobalHotkey 2>/dev/null)" == Control-Option-Shift-Command-2 ]]; }

# guide <check> <settings-url> <title> <instruction>
#   <check> is a command that succeeds once the step is done; with
#   needs_confirmation the user confirms with Enter.
guide() {
    local check="$1" url="$2" title="$3" instruction="$4"
    if "$check"; then
        ok "$title: already done"
        return 0
    fi
    if [[ "$ASSUME_YES" == 1 || "$DRY_RUN" == 1 ]]; then
        pending "$title — $instruction"
        return 0
    fi
    echo -e "\n${bold}  $title${nc}\n    $instruction"
    [[ -n "$url" ]] && open "$url"
    if [[ "$check" == needs_confirmation ]]; then
        echo -ne "    ${dim}Press Enter when done, or type 's' + Enter to do it later:${nc} "
        read -r answer
        if [[ "$answer" == s ]]; then pending "$title — $instruction"; else ok "$title: done"; fi
        return 0
    fi
    echo -ne "    ${dim}Waiting for it… (Enter to do it later)${nc}"
    while ! "$check"; do
        if read -r -t 2 _; then
            echo
            pending "$title — $instruction"
            return 0
        fi
    done
    echo
    ok "$title: done"
}

macos_guided_permissions() {
    local components=" $* "
    section "permissions" "one-time approvals macOS does not let scripts grant"
    if [[ "$components" == *" wm "* ]]; then
        [[ "$DRY_RUN" == 1 || "$ASSUME_YES" == 1 ]] || open -a AeroSpace
        guide aerospace_trusted "$SETTINGS_PRIVACY_ACCESSIBILITY" "AeroSpace" \
            "System Settings > $(accessibility_pane): turn on AeroSpace."
    fi
    if [[ "$components" == *" keyboard "* ]]; then
        # Karabiner registers its background services the first time the app opens.
        [[ "$DRY_RUN" == 1 || "$ASSUME_YES" == 1 ]] || open -a Karabiner-Elements
        guide karabiner_daemon_running "$SETTINGS_LOGIN_ITEMS" "Karabiner background service" \
            "System Settings > General > Login Items & Extensions > Background App Activity: turn on 'Karabiner-Elements Privileged Daemons v2'."
        guide karabiner_driver_enabled "" "Karabiner driver" \
            "Karabiner asks to use a driver extension: click 'Open System Settings' and turn it on (Login Items & Extensions > Driver Extensions)."
        guide needs_confirmation "$SETTINGS_PRIVACY_ACCESSIBILITY" "Karabiner core service" \
            "System Settings > $(accessibility_pane): turn on Karabiner-Core-Service."
        guide spanish_iso_enabled "$SETTINGS_KEYBOARD" "Spanish keyboard" \
            "System Settings > Keyboard > Text Input > Edit > + > Spanish - ISO."
        if [[ -d /Applications/Raycast.app ]]; then
            [[ "$DRY_RUN" == 1 || "$ASSUME_YES" == 1 ]] || raycast_hotkey_set || open -a Raycast
            guide raycast_hotkey_set "" "Raycast hotkey" \
                "Raycast: Cmd+, > General > Raycast Hotkey > click it and press Left Option + d."
        fi
    fi
    if [[ "$components" == *" apps "* ]]; then
        pending "Optional: hide Raycast's menu-bar icon (System Settings > Menu Bar, or Raycast Settings)."
    fi
}

# A double-clickable way back that does not depend on the keyboard layer or a
# terminal: Spotlight "Dotfiles Rescue".
macos_install_rescue_app() {
    local app="$HOME/Applications/Dotfiles Rescue.app"
    if [[ -d "$app" ]]; then
        info "ok (already installed): $app"
        return 0
    fi
    run_cmd mkdir -p "$HOME/Applications"
    # shellcheck disable=SC2016
    run_cmd osacompile -o "$app" \
        -e 'do shell script "PATH=/opt/homebrew/bin:/usr/local/bin:$PATH \"$HOME/.local/bin/dotfiles\" rescue > /tmp/dotfiles-rescue.log 2>&1"' \
        -e 'display dialog "Stock keyboard, windows back on screen, original macOS settings." buttons {"OK"} default button 1 with title "Dotfiles Rescue"'
    state_add apps "$app"
    [[ "$DRY_RUN" == 1 ]] || ok "  installed: $app (Spotlight: Dotfiles Rescue)"
}
