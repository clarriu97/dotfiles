#!/usr/bin/env bash
# PreToolUse hook for file tools: keeps .env secrets out of the conversation
# while letting committed templates (.env.example, .env.sample, .env.template) through.
# Exit 2 blocks the tool call and shows the reason to Claude.
input="$(cat)"
path="$(jq -r '.tool_input | .file_path // .path // empty' <<< "$input" 2>/dev/null)"
glob="$(jq -r '.tool_input.glob // empty' <<< "$input" 2>/dev/null)"

for name in "${path##*/}" "${glob##*/}"; do
    case "$name" in
        .env.example | .env.sample | .env.template) ;;
        .env | .env.* | .env\**)
            echo "Blocked by ~/.claude/hooks/guard-env.sh: $name may contain secrets. Load it in a command instead (set -a; . ./.env; set +a)." >&2
            exit 2
            ;;
    esac
done

exit 0
