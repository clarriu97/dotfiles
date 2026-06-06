#!/usr/bin/env bash
# Highlights the active AeroSpace workspace. $1 = this item's workspace id.
# $FOCUSED_WORKSPACE arrives with the aerospace_workspace_change event; at
# startup it is queried directly from aerospace.

ACCENT=0xff7aa2f7
ACCENT_FG=0xff1a1b26
FG=0xffc0caf5

SID="$1"
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"

if [ "$SID" = "$FOCUSED" ]; then
    sketchybar --set "$NAME" background.drawing=on \
                             background.color="$ACCENT" \
                             label.color="$ACCENT_FG"
else
    sketchybar --set "$NAME" background.drawing=off \
                             label.color="$FG"
fi
