#!/usr/bin/env bash
# tests/lint.sh — static checks for every config file in the repo.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
failed=0

check() {
    local name="$1"
    shift
    if "$@"; then
        echo "ok   $name"
    else
        echo "FAIL $name"
        failed=1
    fi
}

tracked() {
    git ls-files -co --exclude-standard "$@" | while read -r f; do
        if [[ -f "$f" ]]; then echo "$f"; fi
    done
}

shell_files() {
    tracked | while read -r f; do
        case "$f" in
            shell/plugins/*|shell/zshrc.*|shell/.zshrc|shell/.p10k.zsh) continue ;;
            *.sh|*.bash) echo "$f" ;;
            *) head -n1 "$f" 2>/dev/null | grep -qE '^#!.*[/ ](ba)?sh$' && echo "$f" ;;
        esac
    done
}

# shellcheck disable=SC2329
each() {
    local cmd="$1" f
    shift
    for f in "$@"; do
        $cmd "$f" || { echo "  in: $f"; return 1; }
    done
}

SHELL_FILES=()
while read -r f; do SHELL_FILES+=("$f"); done < <(shell_files)
ZSH_FILES=()
while read -r f; do ZSH_FILES+=("$f"); done < <(tracked 'shell/.zshrc' 'shell/zshrc.*.sh' 'shell/.p10k.zsh')
JSON_FILES=()
while read -r f; do JSON_FILES+=("$f"); done < <(tracked '*.json')
TOML_FILES=()
while read -r f; do TOML_FILES+=("$f"); done < <(tracked '*.toml')

check "shellcheck (${#SHELL_FILES[@]} files)" shellcheck -x "${SHELL_FILES[@]}"
check "zsh syntax (${#ZSH_FILES[@]} files)" each "zsh -n" "${ZSH_FILES[@]}"
check "json (${#JSON_FILES[@]} files)" each "jq empty" "${JSON_FILES[@]}"
check "toml (${#TOML_FILES[@]} files)" taplo check --no-schema "${TOML_FILES[@]}"
if command -v check-jsonschema >/dev/null 2>&1; then
    check "claude settings schema" check-jsonschema --schemafile https://json.schemastore.org/claude-code-settings.json claude/settings.json
else
    echo "skip claude settings schema (install check-jsonschema)"
fi
if command -v i3 >/dev/null 2>&1; then
    check "i3 config" i3 -C -c wm/linux/i3/config
fi

exit "$failed"
