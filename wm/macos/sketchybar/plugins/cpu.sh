#!/usr/bin/env bash
# CPU usage (user + system percentage).

CPU="$(top -l 1 | awk '/CPU usage/ {gsub("%",""); print int($3 + $5)}')"
sketchybar --set "$NAME" label="${CPU:-0}%"
