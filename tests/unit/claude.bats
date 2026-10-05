#!/usr/bin/env bats

setup() {
    REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    GUARD="$REPO/claude/hooks/guard-bash.sh"
    STATUSLINE="$REPO/claude/statusline.sh"
}

guard() {
    jq -n --arg c "$1" '{tool_name: "Bash", tool_input: {command: $c}}' | "$GUARD"
}

@test "guard blocks recursive deletes of / and home" {
    for c in "rm -rf /" "rm -rf ~" "rm -rf ~/" "rm -fr \$HOME" "sudo rm -rf /*" "cd /tmp && rm -Rf ~/" "rm -r -f /"; do
        run guard "$c"
        [ "$status" -eq 2 ] || { echo "not blocked: $c"; return 1; }
    done
}

@test "guard allows ordinary deletes" {
    for c in "rm -rf node_modules" "rm -rf ./build" "rm -rf ~/projects/tmp" "rm -f /tmp/file" "rm -rf \$HOME/.cache/foo"; do
        run guard "$c"
        [ "$status" -eq 0 ] || { echo "blocked: $c"; return 1; }
    done
}

@test "guard blocks force pushes but allows --force-with-lease" {
    run guard "git push --force origin main"
    [ "$status" -eq 2 ]
    run guard "git push -f"
    [ "$status" -eq 2 ]
    run guard "git push --force-with-lease origin feature"
    [ "$status" -eq 0 ]
    run guard "git push -u origin HEAD"
    [ "$status" -eq 0 ]
}

@test "guard blocks disk formatting and SIP changes" {
    for c in "mkfs.ext4 /dev/sda1" "dd if=/dev/zero of=/dev/disk2" "diskutil eraseDisk APFS X disk2" "sudo csrutil disable"; do
        run guard "$c"
        [ "$status" -eq 2 ] || { echo "not blocked: $c"; return 1; }
    done
}

@test "guard ignores non-command input" {
    run bash -c "echo '{}' | '$GUARD'"
    [ "$status" -eq 0 ]
}

@test "status line shows model, directory, branch, context and rate limit" {
    run bash -c "jq -n --arg d '$REPO' '{model: {display_name: \"Opus\"}, workspace: {current_dir: \$d}, context_window: {used_percentage: 42.5}, rate_limits: {five_hour: {used_percentage: 81}}}' | '$STATUSLINE'"
    [ "$status" -eq 0 ]
    [[ "$output" == *Opus* ]]
    [[ "$output" == *"${REPO##*/}"* ]]
    [[ "$output" == *"ctx 42%"* ]]
    [[ "$output" == *"5h 81%"* ]]
    [[ "$output" == *"$(git -C "$REPO" branch --show-current)"* ]]
}

@test "status line survives missing fields" {
    run bash -c "echo '{}' | '$STATUSLINE'"
    [ "$status" -eq 0 ]
    [[ "$output" == *Claude* ]]
}

@test "every enabled plugin comes from a declared marketplace" {
    run jq -e '(.extraKnownMarketplaces | keys) as $m | [.enabledPlugins | keys[] | split("@")[1]] | all(. as $x | $m | index($x))' "$REPO/claude/settings.json"
    [ "$status" -eq 0 ]
}
