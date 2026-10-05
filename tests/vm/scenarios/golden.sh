#!/usr/bin/env bash
# Scenario 2 — permissions approved (run with: vm.sh run golden golden).
# Real keystrokes through the virtual keyboard -> Karabiner -> AeroSpace.
# lmeta / rmeta are the left / right Option keys over VNC.

# shellcheck disable=SC2016
ALL=terminal,apps,wm,keyboard,desktop,claude

focused() { remote 'aerospace list-workspaces --focused' 2>/dev/null; }

expect_workspace() {
    local want="$1" got
    sleep 1
    got="$(focused)"
    if [[ "$got" == "$want" ]]; then pass "$2 -> workspace $want"; else fail "$2 -> workspace $want (got '$got')"; fi
}

install_dotfiles "$ALL"
doctor "$ALL"

step "Start AeroSpace (Accessibility already approved in this image)"
remote 'open -a AeroSpace'
sleep 8
expect_remote "AeroSpace answers" 'aerospace list-workspaces --focused'
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
sleep 10
expect_remote "AeroSpace started at login" 'pgrep -x AeroSpace'
expect_remote "JankyBorders started by AeroSpace" 'pgrep -x borders'
desktop_is_usable "4-after-reboot"
vnc "$VM" "combo lmeta+4"
expect_workspace 4 "Left Option + 4 after reboot"
vnc "$VM" "combo lmeta+1"

step "dotfiles rescue with everything active"
if remote '.local/bin/dotfiles rescue' > "$RESULTS/rescue.log" 2>&1; then pass "dotfiles rescue"; else fail "dotfiles rescue (see rescue.log)"; fi
expect_remote "AeroSpace stopped" '! pgrep -x AeroSpace'
typed="$(capture_keys /tmp/golden-rescued.txt "combo lmeta+2" "combo rmeta+2")"
if [[ "$typed" == "@@" ]]; then pass "after rescue both Option keys type @"; else fail "after rescue: expected '@@', got '$typed'"; fi
desktop_is_usable "5-after-rescue"
