#!/usr/bin/env bash
# PreToolUse hook for file tools: keeps .env secrets out of the conversation
# while letting committed templates (.env.example, .env.sample, .env.template) through.
# Exit 2 blocks the tool call and shows the reason to Claude.
path="$(jq -r '.tool_input | .file_path // .path // empty' 2>/dev/null)"
name="${path##*/}"

case "$name" in
    .env.example | .env.sample | .env.template) exit 0 ;;
    .env | .env.*)
        echo "Blocked by ~/.claude/hooks/guard-env.sh: $name may contain secrets. Load it in a command instead (set -a; . ./$name; set +a)." >&2
        exit 2
        ;;
esac

exit 0
