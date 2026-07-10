#!/usr/bin/env bash
# Styles an AeroSpace workspace item. $1 = this item's workspace id.
#   focused  -> accent pill + dark label
#   occupied -> bright label
#   empty    -> dimmed label
# $FOCUSED_WORKSPACE arrives with the aerospace_workspace_change event; at
# startup it is queried directly from aerospace.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

ACCENT=0xff7aa2f7
ACCENT_FG=0xff1a1b26
FG=0xffc0caf5
DIM=0xff565f89

SID="$1"
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

if [ "$SID" = "$FOCUSED" ]; then
    sketchybar --set "$NAME" background.drawing=on \
                             background.color="$ACCENT" \
                             label.color="$ACCENT_FG"
elif aerospace list-windows --workspace "$SID" 2>/dev/null | grep -q .; then
    sketchybar --set "$NAME" background.drawing=off label.color="$FG"
else
    sketchybar --set "$NAME" background.drawing=off label.color="$DIM"
fi
