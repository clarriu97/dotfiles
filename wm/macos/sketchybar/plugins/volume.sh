#!/usr/bin/env bash
# Volume: percentage + icon. Driven by the native 'volume_change' event
# ($INFO = new volume level); falls back to osascript when run manually.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

if [ "$SENDER" = "volume_change" ] && [ -n "$INFO" ]; then
    VOLUME="$INFO"
else
    VOLUME="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)"
fi
[ -z "$VOLUME" ] && exit 0

MUTED="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)"

if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
    ICON=$(printf '\xef\x80\xa6')                # U+F026 muted
elif [ "$VOLUME" -ge 50 ]; then
    ICON=$(printf '\xef\x80\xa8')                # U+F028 high
else
    ICON=$(printf '\xef\x80\xa7')                # U+F027 low
fi

sketchybar --set "$NAME" icon="$ICON" label="${VOLUME}%"
