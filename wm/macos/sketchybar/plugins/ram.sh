#!/usr/bin/env bash
# RAM usage: used percentage (100 - free), via memory_pressure.

FREE="$(memory_pressure | awk -F': ' '/free percentage/ {gsub("%",""); print $2}')"
if [ -n "$FREE" ]; then
    USED=$((100 - FREE))
    sketchybar --set "$NAME" label="${USED}%"
fi
