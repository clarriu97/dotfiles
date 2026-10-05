#!/usr/bin/env bats

setup() {
    REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
}

detect() {
    UNAME_S="${2:-Linux}" OS_RELEASE_FILE="$BATS_TEST_DIRNAME/fixtures/$1" \
        bash -c ". '$REPO/lib/detect.sh'; echo \$OS"
}

@test "Darwin is macos" {
    [ "$(detect none Darwin)" = macos ]
}

@test "ubuntu, debian and derivatives use the apt module" {
    [ "$(detect ubuntu)" = ubuntu ]
    [ "$(detect debian)" = ubuntu ]
    [ "$(detect linuxmint)" = ubuntu ]
}

@test "fedora and rhel derivatives use the dnf module" {
    [ "$(detect fedora)" = fedora ]
    [ "$(detect rocky)" = fedora ]
}

@test "other distros are unknown" {
    [ "$(detect arch)" = unknown ]
    [ "$(detect missing-file)" = unknown ]
}
