#!/usr/bin/env bash
# tests/linux/run.sh — full unattended install + verification in a fresh
# Linux container, as a regular user with sudo (like a real machine).
#
#   tests/linux/run.sh <image> [components]
#   tests/linux/run.sh ubuntu:24.04 terminal,claude
#
# Runs locally (Docker / colima) and in CI. A snapshot of the working tree is
# streamed into the container, so the host checkout is never modified and
# later edits do not leak into a running test.
set -euo pipefail

IMAGE="${1:?usage: $0 <image> [components]}"
COMPONENTS="${2:-terminal,apps,wm,claude}"
REPO="$(cd "$(dirname "$0")/../.." && pwd)"

COPYFILE_DISABLE=1 tar -C "$REPO" --exclude .git --exclude .env -cf - . |
    docker run --rm -i -e COMPONENTS="$COMPONENTS" "$IMAGE" bash -euo pipefail -c '
    mkdir /src && tar -C /src -xf -
    if command -v apt-get >/dev/null; then
        apt-get update -qq
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq sudo git curl ca-certificates perl >/dev/null
    else
        dnf install -y -q sudo git curl perl-Time-HiRes findutils procps-ng diffutils >/dev/null
    fi
    useradd -m -s /bin/bash tester
    echo "tester ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/tester
    cp -a /src /home/tester/dotfiles
    chown -R tester: /home/tester/dotfiles
    before="$(sha256sum /home/tester/dotfiles/claude/settings.json)"
    su - tester -c "cd ~/dotfiles && ./install.sh --yes --only $COMPONENTS"
    if [[ "$(sha256sum /home/tester/dotfiles/claude/settings.json)" != "$before" ]]; then
        echo "FAIL: the install modified claude/settings.json in the repo"
        diff <(cd /src && cat claude/settings.json) /home/tester/dotfiles/claude/settings.json || true
        exit 1
    fi
    echo "=== second run must be a no-op for links ==="
    second="$(su - tester -c "cd ~/dotfiles && ./install.sh --yes --only $COMPONENTS")"
    if echo "$second" | grep "linked:"; then echo "FAIL: second run re-linked files"; exit 1; fi
    echo "=== verify ==="
    su - tester -c "cd ~/dotfiles && tests/verify.sh --only $COMPONENTS"
'
