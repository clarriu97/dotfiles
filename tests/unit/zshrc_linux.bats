#!/usr/bin/env bats

setup() {
    REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    BIN="$BATS_TEST_TMPDIR/bin"
    mkdir -p "$BIN"
    printf '#!/bin/sh\necho "$@"\n' > "$BIN/sudo"
    chmod +x "$BIN/sudo"
}

update() {
    PATH="$BIN" "$(command -v zsh)" -fc "source '$REPO/shell/zshrc.linux.sh'; update"
}

@test "update uses dnf when available" {
    printf '#!/bin/sh\n' > "$BIN/dnf"
    chmod +x "$BIN/dnf"
    [ "$(update)" = "dnf upgrade -y --refresh" ]
}

@test "update falls back to apt-get" {
    [ "$(update)" = $'apt-get update -y\napt-get upgrade -y' ]
}
