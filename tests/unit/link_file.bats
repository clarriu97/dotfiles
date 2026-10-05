#!/usr/bin/env bats

setup() {
    REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    WORK="$(mktemp -d)"
    SRC="$WORK/src"
    echo source > "$SRC"
    DEST="$WORK/home/.config/app/file"
    # shellcheck source=../../lib/common.sh
    . "$REPO/lib/common.sh"
}

teardown() {
    rm -rf "$WORK"
}

@test "creates the symlink and missing parent directories" {
    link_file "$SRC" "$DEST"
    [ -L "$DEST" ]
    [ "$(readlink "$DEST")" = "$SRC" ]
}

@test "is idempotent" {
    link_file "$SRC" "$DEST"
    run link_file "$SRC" "$DEST"
    [ "$status" -eq 0 ]
    [[ "$output" == *"already linked"* ]]
    [ "$(find "$WORK/home" -name 'file*' | wc -l | tr -d ' ')" = 1 ]
}

@test "backs up an existing file before replacing it" {
    mkdir -p "$(dirname "$DEST")"
    echo previous > "$DEST"
    link_file "$SRC" "$DEST"
    [ -L "$DEST" ]
    backup="$(ls "$DEST".bak-*)"
    [ "$(cat "$backup")" = previous ]
}

@test "fails when the source does not exist" {
    run link_file "$WORK/missing" "$DEST"
    [ "$status" -ne 0 ]
    [ ! -e "$DEST" ]
}

@test "dry run changes nothing" {
    mkdir -p "$(dirname "$DEST")"
    echo previous > "$DEST"
    DRY_RUN=1 link_file "$SRC" "$DEST"
    [ ! -L "$DEST" ]
    [ "$(cat "$DEST")" = previous ]
    [ -z "$(ls "$DEST".bak-* 2>/dev/null)" ]
}
