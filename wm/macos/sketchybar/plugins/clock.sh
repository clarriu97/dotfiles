#!/usr/bin/env bash
# Clock: date and time (same format as polybar: dd-mm-YYYY HH:MM).

sketchybar --set "$NAME" label="$(date '+%d-%m-%Y %H:%M')"
