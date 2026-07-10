#!/usr/bin/env bash
# Clock: date and time (same format as polybar: dd-mm-YYYY HH:MM).
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

sketchybar --set "$NAME" label="$(date '+%d-%m-%Y %H:%M')"
