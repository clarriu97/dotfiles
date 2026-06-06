#!/usr/bin/env bash
# Battery: percentage + icon based on level/charging state (uses pmset).

PERCENT="$(pmset -g batt | grep -Eo '[0-9]+%' | head -n1 | tr -d '%')"
CHARGING="$(pmset -g batt | grep -c 'AC Power')"

[ -z "$PERCENT" ] && exit 0

if [ "$CHARGING" -gt 0 ]; then
    ICON=""
else
    case "$PERCENT" in
        100|9[0-9]) ICON="" ;;
        [7-8][0-9]) ICON="" ;;
        [4-6][0-9]) ICON="" ;;
        [2-3][0-9]) ICON="" ;;
        *)          ICON="" ;;
    esac
fi

sketchybar --set "$NAME" icon="$ICON" label="${PERCENT}%"
