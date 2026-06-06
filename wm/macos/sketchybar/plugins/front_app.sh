#!/usr/bin/env bash
# Shows the name of the front-most application.

if [ "$SENDER" = "front_app_switched" ]; then
    sketchybar --set "$NAME" label="$INFO"
fi
