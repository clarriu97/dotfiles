#!/usr/bin/env bash
# Shows the front-most application's real macOS icon (front_app_icon item)
# and its name (front_app item).
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

if [ "$SENDER" = "front_app_switched" ]; then
    sketchybar --set front_app label="$INFO" \
               --set front_app_icon background.image="app.$INFO"
fi
