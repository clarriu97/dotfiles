#!/usr/bin/env bats

setup() {
    REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    FAKE_HOME="$(mktemp -d)"
}

teardown() {
    rm -rf "$FAKE_HOME"
}

install() {
    HOME="$FAKE_HOME" "$REPO/install.sh" "$@"
}

@test "--help exits 0 and lists the flags" {
    run install --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"--dry-run"* ]]
    [[ "$output" == *"--only"* ]]
}

@test "unknown flags exit 2" {
    run install --bogus
    [ "$status" -eq 2 ]
}

@test "unknown components exit 2" {
    run install --yes --dry-run --only terminal,bogus
    [ "$status" -eq 2 ]
    [[ "$output" == *"Unknown component 'bogus'"* ]]
}

@test "keyboard is a macOS-only component" {
    run install --yes --dry-run --os ubuntu --only keyboard
    [ "$status" -eq 2 ]
}

@test "unsupported OS exits 1" {
    run install --yes --dry-run --os windows
    [ "$status" -eq 1 ]
}

@test "dry run of every component writes nothing to HOME" {
    run install --yes --dry-run
    [ "$status" -eq 0 ]
    [[ "$output" == *"Done!"* ]]
    [ -z "$(find "$FAKE_HOME" -mindepth 1)" ]
}

@test "interactive menu selects components by number" {
    run bash -c "printf '1 3\n\n' | HOME='$FAKE_HOME' '$REPO/install.sh' --dry-run"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Components: "*"terminal wm"* ]]
}

@test "interactive menu rejects invalid numbers" {
    run bash -c "printf '42\n' | HOME='$FAKE_HOME' '$REPO/install.sh' --dry-run"
    [ "$status" -eq 2 ]
}

@test "declining the confirmation cancels" {
    run bash -c "printf '\nn\n' | HOME='$FAKE_HOME' '$REPO/install.sh' --dry-run"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Cancelled"* ]]
}
