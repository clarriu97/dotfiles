#!/usr/bin/env bash
# Wi-Fi: shows the SSID if available, else the IP, else "off".
# Written defensively so it never breaks the bar.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

WIFI_ON=$(printf '\xef\x87\xab')     # U+F1EB  wifi
WIFI_OFF=$(printf '\xef\x81\x9e')    # U+F05E  ban / no connection

# Find the Wi-Fi hardware device (usually en0), robust across machines.
WIFI_DEV="$(networksetup -listallhardwareports 2>/dev/null \
    | awk '/Wi-Fi|AirPort/{getline; print $2; exit}')"
WIFI_DEV="${WIFI_DEV:-en0}"

# SSID: ipconfig getsummary works on modern macOS (needs Location Services);
# fall back to networksetup for older releases.
SSID="$(ipconfig getsummary "$WIFI_DEV" 2>/dev/null | grep -m1 ' SSID ' | sed 's/.*SSID : //')"
[ -z "$SSID" ] && SSID="$(networksetup -getairportnetwork "$WIFI_DEV" 2>/dev/null | sed -n 's/^Current Wi-Fi Network: //p')"

IP="$(ipconfig getifaddr "$WIFI_DEV" 2>/dev/null)"

if [ -n "$SSID" ]; then
    sketchybar --set "$NAME" icon="$WIFI_ON" label="$SSID"
elif [ -n "$IP" ]; then
    sketchybar --set "$NAME" icon="$WIFI_ON" label="$IP"
else
    sketchybar --set "$NAME" icon="$WIFI_OFF" label="off"
fi
