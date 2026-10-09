#!/usr/bin/env bash
# claude/agent-skills-diff.sh — Markdown summary of what changed in the vendored
# addyosmani/agent-skills between two commits.
#
#   claude/agent-skills-diff.sh [old] [new]
#
# Defaults: old = commit checked out in the submodule, new = upstream default branch.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR="${AGENT_SKILLS_DIR:-$DOTFILES_DIR/vendor/agent-skills}"
REPO_URL="https://github.com/addyosmani/agent-skills"

vgit() { git -C "$VENDOR" "$@"; }

if [[ $# -lt 2 ]]; then
    vgit fetch --quiet origin
fi
old="$(vgit rev-parse "${1:-HEAD}")"
new="$(vgit rev-parse "${2:-origin/HEAD}")"

version_at() {
    vgit show "$1:.claude-plugin/plugin.json" 2>/dev/null | jq -r '.version // "?"' || echo "?"
}

description_at() {
    vgit show "$1:skills/$2/SKILL.md" 2>/dev/null | sed -n 's/^description: *//p' | head -n1
}

changed() {
    vgit diff --name-status "$old" "$new" -- "$@"
}

names() {
    local tick=$'\x60'
    sed -E 's#^[^/]*/##; s#/.*##; s#\.md$##' | sort -u | sed "s/.*/$tick&$tick/" | paste -sd, - | sed 's/,/, /g'
}

if [[ "$old" == "$new" ]]; then
    echo "agent-skills is up to date (${old:0:7}, version $(version_at "$old"))."
    exit 0
fi

commits="$(vgit rev-list --count "$old..$new")"
echo "## agent-skills $(version_at "$old") → $(version_at "$new")"
echo
echo "$commits commits: [${old:0:7}...${new:0:7}]($REPO_URL/compare/$old...$new)"

skills="$(changed skills | awk '$2 ~ /\/SKILL\.md$/ {print $1, $2}')"
added="$(awk '$1 == "A" {print $2}' <<<"$skills" | names)"
removed="$(awk '$1 == "D" {print $2}' <<<"$skills" | names)"
modified="$(changed skills | awk '$1 != "A" && $1 != "D" {print $2}' | names)"

echo
echo "### Skills"
echo
echo "- Added: ${added:-none}"
echo "- Removed: ${removed:-none}"
echo "- Modified: ${modified:-none}"

described=""
while read -r skill; do
    [[ -n "$skill" ]] || continue
    before="$(description_at "$old" "$skill")"
    after="$(description_at "$new" "$skill")"
    if [[ -n "$before" && -n "$after" && "$before" != "$after" ]]; then
        described+=$'\n'"- \`$skill\`"$'\n'"  - before: $before"$'\n'"  - after: $after"
    fi
done < <(changed skills | awk '$1 == "M" && $2 ~ /\/SKILL\.md$/ {print $2}' | cut -d/ -f2)

if [[ -n "$described" ]]; then
    echo
    echo "### Descriptions changed (they decide when a skill triggers)"
    echo "$described"
fi

for area in .claude/commands agents hooks references; do
    files="$(changed "$area" | awk '{print $1, $NF}')"
    [[ -n "$files" ]] || continue
    echo
    echo "### \`$area\`"
    echo
    sed -E 's/^A /- added: /; s/^D /- removed: /; s/^[MRT][0-9]* /- modified: /' <<<"$files"
done

echo
echo "### Commits"
echo
echo '```'
vgit log --oneline --no-decorate "$old..$new"
echo '```'
echo
echo "### Files"
echo
echo '```'
vgit diff --stat "$old" "$new"
echo '```'
