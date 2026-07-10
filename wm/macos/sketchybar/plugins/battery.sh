#!/usr/bin/env bash
# Battery: percentage + icon, colored by level/charging state (uses pmset).
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

PERCENT="$(pmset -g batt | grep -Eo '[0-9]+%' | head -n1 | tr -d '%')"
CHARGING="$(pmset -g batt | grep -c 'AC Power')"
[ -z "$PERCENT" ] && exit 0

# Nerd Font battery glyphs (FA, UTF-8 bytes): full -> empty
case "$PERCENT" in
    100|9[0-9]|8[0-9]) ICON=$(printf '\xef\x89\x80') ;;   # U+F240 full
    [6-7][0-9])        ICON=$(printf '\xef\x89\x81') ;;   # U+F241 three quarters
    [4-5][0-9])        ICON=$(printf '\xef\x89\x82') ;;   # U+F242 half
    [2-3][0-9])        ICON=$(printf '\xef\x89\x83') ;;   # U+F243 quarter
    *)                 ICON=$(printf '\xef\x89\x84') ;;   # U+F244 empty
esac

if [ "$CHARGING" -gt 0 ]; then
    COLOR=0xff9ece6a                                       # green while plugged in
elif [ "$PERCENT" -le 20 ]; then
    COLOR=0xfff7768e                                       # red when low
elif [ "$PERCENT" -le 40 ]; then
    COLOR=0xffe0af68                                       # yellow
else
    COLOR=0xffc0caf5
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENT}%"
