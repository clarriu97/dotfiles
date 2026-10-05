#!/usr/bin/env bash
# PreToolUse hook for Bash: blocks a short list of catastrophic commands.
# Exit 2 blocks the tool call and shows the reason to Claude.
command="$(jq -r '.tool_input.command // empty' 2>/dev/null)"

block() {
    echo "Blocked by ~/.claude/hooks/guard-bash.sh: $1" >&2
    exit 2
}

# shellcheck disable=SC2016
home_or_root='(/|/\*|~|~/|~/\*|\$HOME|\$HOME/|\$HOME/\*|\$\{HOME\}|\$\{HOME\}/)'
if [[ "$command" =~ (^|[;&|[:space:]])rm[[:space:]]+(-[[:alnum:]-]+[[:space:]]+)*-[[:alnum:]]*[rR][[:alnum:]]*([[:space:]]+-[[:alnum:]-]+)*[[:space:]]+${home_or_root}([[:space:]]|$) ]]; then
    block "recursive delete of / or the home directory."
fi

if [[ "$command" =~ (^|[;&|[:space:]])git[[:space:]]+push([[:space:]]|$) ]] &&
    [[ "$command" =~ [[:space:]](--force|-f)([[:space:]]|$) ]]; then
    block "force push. Use --force-with-lease instead."
fi

if [[ "$command" =~ (^|[;&|[:space:]])(mkfs(\.[[:alnum:]]+)?|diskutil[[:space:]]+(erase[[:alnum:]]*|zeroDisk|secureErase|partitionDisk|reformat))([[:space:]]|$) ]] ||
    [[ "$command" =~ (^|[;&|[:space:]])dd[[:space:]].*of=/dev/ ]]; then
    block "disk formatting or raw device writes."
fi

if [[ "$command" =~ (^|[;&|[:space:]])(sudo[[:space:]]+)?csrutil[[:space:]]+disable ]]; then
    block "disabling System Integrity Protection."
fi

exit 0
