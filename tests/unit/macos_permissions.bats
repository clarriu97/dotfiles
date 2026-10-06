#!/usr/bin/env bats

setup() {
    REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    STUBS="$(mktemp -d)"
    . "$REPO/lib/common.sh"
    . "$REPO/lib/macos-permissions.sh"
}

teardown() {
    rm -rf "$STUBS"
}

with_macos() {
    printf '#!/bin/sh\necho %s\n' "$1" > "$STUBS/sw_vers"
    chmod +x "$STUBS/sw_vers"
    PATH="$STUBS:$PATH" accessibility_pane
}

@test "macOS 27 and later call the pane Device Control and Data Access" {
    [[ "$(with_macos 27.0.1)" == *"Device Control and Data Access" ]]
    [[ "$(with_macos 28.1)" == *"Device Control and Data Access" ]]
}

@test "macOS 26 and earlier call the pane Accessibility" {
    [[ "$(with_macos 26.4)" == *"> Accessibility" ]]
    [[ "$(with_macos 15.7)" == *"> Accessibility" ]]
}

@test "unattended runs list the approvals instead of opening System Settings" {
    ASSUME_YES=1
    guide needs_confirmation "x-apple.systempreferences:test" "Step" "Do the thing."
    [ "${#PENDING[@]}" -eq 1 ]
    [[ "${PENDING[0]}" == "Step — Do the thing." ]]
}
