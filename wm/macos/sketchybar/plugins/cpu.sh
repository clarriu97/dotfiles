#!/usr/bin/env bash
# CPU usage (user + system percentage).
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

CPU="$(top -l 1 | awk '/CPU usage/ {gsub("%",""); print int($3 + $5)}')"
sketchybar --set "$NAME" label="${CPU:-0}%"
