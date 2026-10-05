#!/usr/bin/env bash
# Helpers for VM scenarios. Sourced by `vm.sh run` with VM and RESULTS set and
# the vm.sh functions (vm_ssh, vnc, shot, reboot_vm, ...) available.

FAILURES=0

step() { printf '\n\033[1;34m== %s\033[0m\n' "$*"; }
pass() { printf '\033[0;32mPASS\033[0m %s\n' "$*"; }
fail() { printf '\033[0;31mFAIL\033[0m %s\n' "$*"; FAILURES=$((FAILURES + 1)); }

remote() { vm_ssh "$VM" "export PATH=/opt/homebrew/bin:\$HOME/.local/bin:\$PATH; $*"; }

# expect_remote <description> <remote shell command>
expect_remote() {
    local desc="$1"
    shift
    if remote "$@" >/dev/null 2>&1; then pass "$desc"; else fail "$desc"; fi
}

screenshot() { shot "$VM" "$RESULTS/screens/$1.png"; }

install_dotfiles() {
    step "install.sh --yes --only $1"
    if remote "cd ~/dotfiles && ./install.sh --yes --only $1" > "$RESULTS/install-$1.log" 2>&1; then
        pass "install.sh --only $1"
    else
        fail "install.sh --only $1 (see install-$1.log)"
    fi
}

doctor() {
    step "doctor --only $1"
    remote "cd ~/dotfiles && tests/verify.sh --only $1" | tee "$RESULTS/doctor-$1.log" | grep -vE '^.{0,12}PASS' || true
    if grep -q 'All checks passed' "$RESULTS/doctor-$1.log"; then pass "doctor --only $1"; else fail "doctor --only $1"; fi
}

# shellcheck disable=SC2016
desktop_is_usable() {
    step "Desktop usable: $1"
    expect_remote "Dock running" pgrep -x Dock
    expect_remote "Finder running" pgrep -x Finder
    expect_remote "menu bar (SystemUIServer) running" pgrep -x SystemUIServer
    expect_remote "native menu bar not hidden" '[ "$(defaults read -g _HIHideMenuBar 2>/dev/null || echo 0)" = 0 ]'
    expect_remote "Dock not hidden off-screen" '[ "$(defaults read com.apple.dock autohide-delay 2>/dev/null || echo 0)" != 1000 ]'
    screenshot "$1"
}

# capture_keys <file> <vnc commands...>: opens a Terminal running `cat > <file>`
# on the VM, sends the keystrokes (physical keys, so the VM's Spanish layout
# applies), ends with Ctrl-D and prints what the keyboard produced.
capture_keys() {
    local file="$1"
    shift
    remote "rm -f $file; printf '#!/bin/sh\\ncat > $file\\n' > /tmp/capture.command; chmod +x /tmp/capture.command; open /tmp/capture.command" >/dev/null
    sleep 5
    vnc "$VM" "$@" "key return" "combo ctrl+d" "sleep 1"
    remote "cat $file; osascript -e 'quit app \"Terminal\"' >/dev/null 2>&1 || killall Terminal" 2>/dev/null
}

finish() {
    echo
    if [[ "$FAILURES" -gt 0 ]]; then
        printf '\033[0;31m%d check(s) failed\033[0m\n' "$FAILURES"
        return 1
    fi
    printf '\033[0;32mScenario passed\033[0m\n'
}
