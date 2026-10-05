#!/usr/bin/env bash
# Scenario 1 — the one that broke the real Mac: a fresh macOS, every component
# installed, NO permission approved (no Accessibility, no Karabiner driver).
# The Mac must stay fully usable, survive a reboot, and `dotfiles rescue` /
# `dotfiles uninstall` must bring it back to stock.

# shellcheck disable=SC2016
ALL=terminal,apps,wm,keyboard,claude

desktop_is_usable "1-before-install"

install_dotfiles "$ALL"
doctor "$ALL"

step "Start AeroSpace without Accessibility permission (as a user would)"
remote 'open -a AeroSpace' || true
sleep 8
screenshot "2-aerospace-without-permission"

reboot_vm "$VM"
desktop_is_usable "3-after-reboot"

step "Keyboard after reboot (Karabiner installed, driver not approved)"
typed="$(capture_keys /tmp/fresh-keys.txt "type hola" "key space" "combo rmeta+2" "combo lmeta+2" "key ;")"
echo "typed: $typed"
if [[ "$typed" == "hola @@ñ" ]]; then pass "keyboard unchanged: 'hola @@ñ'"; else fail "keyboard unchanged: expected 'hola @@ñ', got '$typed'"; fi
screenshot "4-after-typing"

step "Windows stay on screen"
remote 'open -a TextEdit; open ~' || true
sleep 5
screenshot "5-windows"

step "dotfiles rescue"
if remote '~/.local/bin/dotfiles rescue' > "$RESULTS/rescue.log" 2>&1; then pass "dotfiles rescue"; else fail "dotfiles rescue (see rescue.log)"; fi
expect_remote "AeroSpace not running" '! pgrep -x AeroSpace'
expect_remote "AeroSpace config is the rescue config" 'grep -qx "start-at-login = false" ~/.aerospace.toml && [ ! -L ~/.aerospace.toml ]'
expect_remote "Mission Control 'group by app' back to stock" '! defaults read com.apple.dock expose-group-apps >/dev/null 2>&1'
expect_remote "'Displays have separate Spaces' back to stock" '! defaults read com.apple.spaces spans-displays >/dev/null 2>&1'
desktop_is_usable "6-after-rescue"

step "dotfiles uninstall"
if remote '~/.local/bin/dotfiles uninstall' > "$RESULTS/uninstall.log" 2>&1; then pass "dotfiles uninstall"; else fail "dotfiles uninstall (see uninstall.log)"; fi
expect_remote "no links into ~/dotfiles remain" '[ -z "$(find ~ -maxdepth 4 -type l -lname "$HOME/dotfiles/*" 2>/dev/null)" ]'
expect_remote "karabiner.json removed" '[ ! -e ~/.config/karabiner/karabiner.json ]'

reboot_vm "$VM"
desktop_is_usable "7-after-uninstall-reboot"
typed="$(capture_keys /tmp/fresh-keys2.txt "type adios" "key space" "combo lmeta+3" "combo rmeta+3")"
if [[ "$typed" == "adios ##" ]]; then pass "keyboard stock after uninstall: 'adios ##'"; else fail "keyboard after uninstall: got '$typed'"; fi
