#!/usr/bin/env bash
# tests/vm/vm.sh — disposable macOS VMs (tart) for testing the dotfiles.
#
#   tests/vm/vm.sh base                 vanilla macOS -> dotfiles-base (SSH key, Spanish ISO)
#   tests/vm/vm.sh golden               base -> dotfiles-golden with everything installed
#   tests/vm/vm.sh approve              opens the golden VM so a human approves the permissions once
#   tests/vm/vm.sh run <scenario> [base|golden]
#                                       clone, boot, push the repo, run tests/vm/scenarios/<scenario>.sh,
#                                       collect results in tests/vm/out/<scenario>/, destroy the clone
#   tests/vm/vm.sh up|down|ssh|vnc|shot <vm> ...
#
# Nothing here touches the host beyond ~/.tart and tests/vm/out/.
set -euo pipefail

VM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$VM_DIR/../.." && pwd)"
OUT="$VM_DIR/out"
IMAGE="${DOTFILES_VM_IMAGE:-ghcr.io/cirruslabs/macos-golden-gate-vanilla:latest}"
KEY="$OUT/id_ed25519"
VENV="$VM_DIR/.venv"
PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"
SSH_OPTS=(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=5)

log() { printf '\033[0;36m[vm]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[0;31m[vm] %s\033[0m\n' "$*" >&2; exit 1; }

require() {
    command -v tart >/dev/null || die "tart not found (https://github.com/cirruslabs/tart/releases)."
    command -v sshpass >/dev/null || die "sshpass not found (brew install sshpass)."
    if [[ ! -x "$VENV/bin/python" ]]; then
        log "Creating Python venv for the VNC daemon..."
        python3 -m venv "$VENV"
        "$VENV/bin/pip" -q install -r "$VM_DIR/requirements.txt"
    fi
    mkdir -p "$OUT"
    [[ -f "$KEY" ]] || ssh-keygen -q -t ed25519 -N "" -f "$KEY"
}

state() { mkdir -p "$OUT/$1/state"; echo "$OUT/$1/state"; }

vm_ip() { tart ip "$1" 2>/dev/null; }

vm_ssh() {
    local vm="$1"
    shift
    ssh "${SSH_OPTS[@]}" -i "$KEY" "admin@$(vm_ip "$vm")" "$@"
}

wait_ssh() {
    local vm="$1"
    for _ in $(seq 1 90); do
        if vm_ssh "$vm" true 2>/dev/null; then return 0; fi
        sleep 4
    done
    die "$vm: SSH did not come up."
}

wait_desktop() {
    local vm="$1"
    for _ in $(seq 1 60); do
        if vm_ssh "$vm" 'pgrep -x Dock >/dev/null && pgrep -x Finder >/dev/null' 2>/dev/null; then
            sleep 5
            return 0
        fi
        sleep 3
    done
    die "$vm: desktop (Dock/Finder) did not start."
}

vnc() {
    local vm="$1" s c reply
    shift
    s="$(state "$vm")"
    for c in "$@"; do
        reply="$(printf '%s\n' "$c" | nc 127.0.0.1 "$(cat "$s/vncd.port")")"
        [[ "$reply" == ok ]] || die "vnc '$c': $reply"
    done
}

shot() {
    local vm="$1" file="$2"
    mkdir -p "$(dirname "$file")"
    vnc "$vm" "capture $file"
    sips -Z 1024 "$file" --out "$file" >/dev/null
    log "screenshot: $file"
}

start_vncd() {
    local vm="$1" s url pass port
    s="$(state "$vm")"
    for _ in $(seq 1 30); do
        url="$(grep -o 'vnc://[^ ]*' "$s/tart.log" 2>/dev/null | tail -1)" && [[ -n "$url" ]] && break
        sleep 1
    done
    [[ -n "$url" ]] || die "$vm: no VNC URL in $s/tart.log"
    pass="$(sed -E 's#vnc://:([^@]*)@.*#\1#' <<<"$url")"
    port="$(sed -E 's#.*:([0-9]+)$#\1#' <<<"$url")"
    echo $((port + 10000)) > "$s/vncd.port"
    "$VENV/bin/python" "$VM_DIR/vncd.py" "127.0.0.1::$port" "$pass" "$(cat "$s/vncd.port")" \
        > "$s/vncd.log" 2>&1 &
    echo $! > "$s/vncd.pid"
    for _ in $(seq 1 30); do
        grep -q ready "$s/vncd.log" && return 0
        sleep 1
    done
    die "$vm: VNC daemon did not start ($s/vncd.log)."
}

up() {
    local vm="$1" s
    s="$(state "$vm")"
    log "Booting $vm..."
    tart run "$vm" --no-graphics --vnc-experimental > "$s/tart.log" 2>&1 &
    echo $! > "$s/tart.pid"
    start_vncd "$vm"
    wait_ssh "$vm"
    wait_desktop "$vm"
    log "$vm is up ($(vm_ip "$vm"))."
}

down() {
    local vm="$1" s
    s="$(state "$vm")"
    [[ -f "$s/vncd.pid" ]] && kill "$(cat "$s/vncd.pid")" 2>/dev/null || true
    tart stop "$vm" >/dev/null 2>&1 || true
    rm -f "$s/vncd.pid" "$s/tart.pid"
}

reboot_vm() {
    local vm="$1"
    log "Rebooting $vm..."
    vm_ssh "$vm" 'sudo shutdown -r now' >/dev/null 2>&1 || true
    sleep 15
    down "$vm"
    sleep 3
    up "$vm"
}

push_repo() {
    local vm="$1"
    log "Copying a snapshot of the working tree into $vm:~/dotfiles..."
    COPYFILE_DISABLE=1 tar -C "$REPO" --exclude .git --exclude .env --exclude tests/vm/out \
        --exclude tests/vm/.venv -cf - . | vm_ssh "$vm" 'rm -rf ~/dotfiles && mkdir ~/dotfiles && tar -C ~/dotfiles -xf -'
}

cmd_base() {
    require
    tart list --quiet | grep -qx dotfiles-base && die "dotfiles-base exists (tart delete dotfiles-base to rebuild)."
    tart clone "$IMAGE" dotfiles-base
    tart set dotfiles-base --cpu 4 --memory 6144
    tart run dotfiles-base --no-graphics --vnc-experimental > "$(state dotfiles-base)/tart.log" 2>&1 &
    local ip=""
    for _ in $(seq 1 90); do
        ip="$(vm_ip dotfiles-base)" && sshpass -p admin ssh "${SSH_OPTS[@]}" "admin@$ip" true 2>/dev/null && break
        sleep 4
    done
    log "Installing the test SSH key (the image's documented default credentials are used only here)..."
    sshpass -p admin ssh "${SSH_OPTS[@]}" "admin@$ip" \
        "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" < "$KEY.pub"
    log "Spanish - ISO keyboard layout, no sleep / screen saver..."
    vm_ssh dotfiles-base 'bash -s' <<'EOF'
set -e
layout='<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>87</integer><key>KeyboardLayout Name</key><string>Spanish - ISO</string></dict>'
defaults write com.apple.HIToolbox AppleEnabledInputSources -array "$layout"
defaults write com.apple.HIToolbox AppleSelectedInputSources -array "$layout"
defaults write com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID com.apple.keylayout.Spanish-ISO
sudo pmset -a displaysleep 0 sleep 0 >/dev/null
defaults -currentHost write com.apple.screensaver idleTime 0
EOF
    vm_ssh dotfiles-base 'sudo shutdown -h now' >/dev/null 2>&1 || true
    sleep 20
    tart stop dotfiles-base >/dev/null 2>&1 || true
    log "dotfiles-base ready."
}

cmd_golden() {
    require
    tart list --quiet | grep -qx dotfiles-base || die "Run 'vm.sh base' first."
    tart list --quiet | grep -qx dotfiles-golden && die "dotfiles-golden exists (tart delete dotfiles-golden to rebuild)."
    tart clone dotfiles-base dotfiles-golden
    up dotfiles-golden
    push_repo dotfiles-golden
    log "Installing every component (no permissions yet)..."
    vm_ssh dotfiles-golden 'cd ~/dotfiles && ./install.sh --yes' > "$OUT/golden-install.log" 2>&1 ||
        log "install.sh reported errors, see $OUT/golden-install.log"
    vm_ssh dotfiles-golden 'open -a AeroSpace; open -a Karabiner-Elements' || true
    sleep 5
    down dotfiles-golden
    log "dotfiles-golden prepared. Next: tests/vm/vm.sh approve"
}

cmd_approve() {
    require
    tart list --quiet | grep -qx dotfiles-golden || die "Run 'vm.sh golden' first."
    cat <<EOF

A window with the VM opens now. Approve, once (VM password: admin):
  1. AeroSpace   System Settings > Privacy & Security > Accessibility > enable AeroSpace
  2. Karabiner   System Settings > General > Login Items & Extensions > Driver Extensions > enable
                 System Settings > Privacy & Security > Input Monitoring > enable karabiner_grabber
                 (and karabiner_observer if listed)
Then shut the VM down from the Apple menu (Shut Down...). Every 'golden' scenario clones it.

EOF
    tart run dotfiles-golden
    log "dotfiles-golden saved."
}

cmd_run() {
    local scenario="$1" source="${2:-base}" vm results status=0
    require
    [[ -f "$VM_DIR/scenarios/$scenario.sh" ]] || die "Unknown scenario: $scenario"
    vm="dotfiles-test-$scenario"
    results="$OUT/$scenario"
    rm -rf "$results/screens"
    mkdir -p "$results/screens"
    down "$vm"
    tart delete "$vm" >/dev/null 2>&1 || true
    tart clone "dotfiles-$source" "$vm"
    tart set "$vm" --memory "${DOTFILES_VM_MEMORY:-4096}"
    CLEANUP_VM="$vm"
    trap 'down "$CLEANUP_VM"; [[ -n "${KEEP_VM:-}" ]] || tart delete "$CLEANUP_VM" >/dev/null 2>&1 || true' EXIT
    up "$vm"
    push_repo "$vm"
    export VM="$vm" RESULTS="$results"
    # shellcheck source=/dev/null
    ( . "$VM_DIR/scenarios/lib.sh" && . "$VM_DIR/scenarios/$scenario.sh" && finish ) 2>&1 |
        tee "$results/log.txt" || status=1
    if [[ "$status" == 0 ]]; then
        log "Scenario $scenario PASSED. Results: $results"
    else
        log "Scenario $scenario FAILED. Results: $results"
    fi
    return "$status"
}

main() {
    local cmd="${1:-}"
    shift || true
    case "$cmd" in
        base)   cmd_base ;;
        golden) cmd_golden ;;
        approve) cmd_approve ;;
        run)    cmd_run "$@" ;;
        up)     require; up "$1" ;;
        down)   down "$1" ;;
        ssh)    require; vm_ssh "$@" ;;
        vnc)    require; vnc "$@" ;;
        shot)   require; shot "$@" ;;
        *)      sed -n '2,12p' "$0"; exit 2 ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
