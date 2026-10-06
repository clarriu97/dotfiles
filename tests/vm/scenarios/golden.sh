#!/usr/bin/env bash
# Scenario 2 — permissions approved (run with: vm.sh run golden golden).
# Real keystrokes through the virtual keyboard -> Karabiner -> AeroSpace.
# lmeta / rmeta are the left / right Option keys over VNC.

# shellcheck disable=SC2016
ALL=terminal,apps,wm,keyboard,desktop,claude

# Signed-out first-run windows get in the way of keystrokes in the VM: Claude's
# sign-in page turns on Secure Event Input (hidden from Karabiner's event-tap
# fallback) and Warp's onboarding hands focus back. Signed-in apps on a real Mac
# do neither.
quit_signed_out_apps() {
    remote 'osascript -e "quit app \"Claude\"" -e "quit app \"Warp\""; sleep 3; aerospace workspace 1' || true
}

focused() { remote 'aerospace list-workspaces --focused' 2>/dev/null || true; }

expect_workspace() {
    local want="$1" got
    sleep 1
    got="$(focused)"
    if [[ "$got" == "$want" ]]; then pass "$2 -> workspace $want"; else fail "$2 -> workspace $want (got '$got')"; fi
}

install_dotfiles "$ALL"
doctor "$ALL"

step "Approve the new apps once, as a user does on their first launch"
remote 'xattr -dr com.apple.quarantine /Applications/*.app 2>/dev/null; killall CoreServicesUIAgent 2>/dev/null
    open -a Stats; open /Applications/Caffeine.app' || true

step "Start AeroSpace (Accessibility already approved in this image)"
remote 'open -a AeroSpace'
wait_remote "AeroSpace answers" 'aerospace list-workspaces --focused'
wait_remote "startup layout opened VS Code" 'aerospace list-windows --workspace 4 --format %{app-bundle-id} | grep -qx com.microsoft.VSCode'
sleep 12
quit_signed_out_apps
expect_remote "JankyBorders running" 'pgrep -x borders'
expect_remote "Karabiner driver active" "systemextensionsctl list | grep -q 'Karabiner.*activated enabled'"

step "Workspaces with Left Option"
vnc "$VM" "combo lmeta+2"
expect_workspace 2 "Left Option + 2"
vnc "$VM" "combo lmeta+3"
expect_workspace 3 "Left Option + 3"
vnc "$VM" "combo lmeta+tab"
expect_workspace 2 "Left Option + Tab (back and forth)"
vnc "$VM" "combo lmeta+1"
expect_workspace 1 "Left Option + 1"

step "Right Option and other Left Option combinations still type symbols"
typed="$(capture_keys /tmp/golden-keys.txt "combo rmeta+2" "combo rmeta+3" "combo rmeta+1" "combo lmeta+\\" "key ;")"
echo "typed: $typed"
if [[ "$typed" == "@#|}ñ" ]]; then pass "Right Option + 2/3/1 -> @#|, Left Option + ç -> }, ñ"; else fail "symbols: expected '@#|}ñ', got '$typed'"; fi
expect_workspace 1 "typing symbols did not switch workspace"

step "Windows: open, tile, move to another workspace"
remote 'open -a TextEdit; open -a Finder ~' || true
sleep 5
screenshot "1-tiled"
before="$(remote 'aerospace list-windows --workspace 1 | wc -l' | tr -d ' ')"
vnc "$VM" "combo lmeta+lshift+5"
sleep 2
expect_remote "Left Option + Shift + 5 moved a window to workspace 5" '[ "$(aerospace list-windows --workspace 5 | wc -l)" -ge 1 ]'
after="$(remote 'aerospace list-windows --workspace 1 | wc -l' | tr -d ' ')"
if [[ "$after" -lt "$before" ]]; then pass "workspace 1 has one window less ($before -> $after)"; else fail "workspace 1 windows: $before -> $after"; fi
vnc "$VM" "combo lmeta+5"
expect_workspace 5 "follow the window"
screenshot "2-workspace-5"
vnc "$VM" "combo lmeta+1"

step "Launch a terminal with Left Option + Shift + Enter (Ghostty)"
vnc "$VM" "combo lmeta+lshift+return"
sleep 5
expect_remote "Ghostty opened" 'pgrep -f Ghostty.app'
screenshot "3-ghostty"

reboot_vm "$VM"
step "After reboot"
wait_remote "AeroSpace started at login" 'pgrep -x AeroSpace'
expect_remote "JankyBorders started by AeroSpace" 'pgrep -x borders'
wait_remote "startup layout: Brave on 1" 'aerospace list-windows --workspace 1 --format %{app-bundle-id} | grep -qx com.brave.Browser'
wait_remote "startup layout: Warp on 2" 'aerospace list-windows --workspace 2 --format %{app-bundle-id} | grep -qx dev.warp.Warp-Stable'
wait_remote "startup layout: Claude on 3" 'aerospace list-windows --workspace 3 --format %{app-bundle-id} | grep -qx com.anthropic.claudefordesktop'
wait_remote "startup layout: VS Code on 4" 'aerospace list-windows --workspace 4 --format %{app-bundle-id} | grep -qx com.microsoft.VSCode'
sleep 12
quit_signed_out_apps
expect_remote "Stats started at login" 'pgrep -x Stats'
expect_remote "Caffeine started at login" 'pgrep -x Caffeine'
expect_remote "menu bar lists only occupied workspaces" '[ "$(aerospace list-workspaces --all | wc -l)" -lt 10 ]'
desktop_is_usable "4-after-reboot"
vnc "$VM" "combo lmeta+4"
expect_workspace 4 "Left Option + 4 after reboot"
vnc "$VM" "combo lmeta+1"

step "Dotfiles Rescue app with everything active (no keyboard layer, no terminal)"
remote 'open ~/Applications/Dotfiles\ Rescue.app'
sleep 15
expect_remote "Karabiner switched to the Plain profile" '[ "$("/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli" --show-current-profile-name)" = Plain ]'
vnc "$VM" "key return"
expect_remote "AeroSpace stopped" '! pgrep -x AeroSpace'
typed="$(capture_keys /tmp/golden-rescued.txt "combo lmeta+2" "combo rmeta+2")"
if [[ "$typed" == "@@" ]]; then pass "after rescue both Option keys type @"; else fail "after rescue: expected '@@', got '$typed'"; fi
desktop_is_usable "5-after-rescue"
