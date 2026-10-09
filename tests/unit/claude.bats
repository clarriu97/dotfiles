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

skills_repo() {
    local dir="$BATS_TEST_TMPDIR/agent-skills"
    git init -q "$dir"
    git -C "$dir" config user.email t@t
    git -C "$dir" config user.name t
    mkdir -p "$dir/.claude-plugin" "$dir/skills/kept" "$dir/skills/dropped" "$dir/.claude/commands"
    echo '{"version": "1.0.0"}' > "$dir/.claude-plugin/plugin.json"
    printf -- '---\nname: kept\ndescription: Old trigger.\n---\nBody\n' > "$dir/skills/kept/SKILL.md"
    printf -- '---\nname: dropped\ndescription: Gone.\n---\n' > "$dir/skills/dropped/SKILL.md"
    echo build > "$dir/.claude/commands/build.md"
    git -C "$dir" add -A && git -C "$dir" commit -qm "initial"
    echo '{"version": "1.1.0"}' > "$dir/.claude-plugin/plugin.json"
    printf -- '---\nname: kept\ndescription: New trigger.\n---\nBody\n' > "$dir/skills/kept/SKILL.md"
    git -C "$dir" rm -rq skills/dropped
    mkdir -p "$dir/skills/fresh"
    printf -- '---\nname: fresh\ndescription: New skill.\n---\n' > "$dir/skills/fresh/SKILL.md"
    echo spec > "$dir/.claude/commands/spec.md"
    git -C "$dir" add -A && git -C "$dir" commit -qm "add fresh, drop dropped"
    echo "$dir"
}

@test "agent-skills diff summarizes versions, skills, descriptions and commands" {
    dir="$(skills_repo)"
    run env AGENT_SKILLS_DIR="$dir" "$REPO/claude/agent-skills-diff.sh" HEAD~1 HEAD
    [ "$status" -eq 0 ]
    [[ "$output" == *"agent-skills 1.0.0 → 1.1.0"* ]]
    [[ "$output" == *"Added: \`fresh\`"* ]]
    [[ "$output" == *"Removed: \`dropped\`"* ]]
    [[ "$output" == *"Modified: \`kept\`"* ]]
    [[ "$output" == *"before: Old trigger."* ]]
    [[ "$output" == *"after: New trigger."* ]]
    [[ "$output" == *"added: .claude/commands/spec.md"* ]]
    [[ "$output" == *"add fresh, drop dropped"* ]]
}

@test "agent-skills diff reports when nothing changed" {
    dir="$(skills_repo)"
    run env AGENT_SKILLS_DIR="$dir" "$REPO/claude/agent-skills-diff.sh" HEAD HEAD
    [ "$status" -eq 0 ]
    [[ "$output" == *"up to date"* ]]
}
