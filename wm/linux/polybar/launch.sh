#!/usr/bin/env bash
# Launch polybar, auto-detecting the machine's network interface and battery.

# Terminate previous instances
polybar-msg cmd quit 2>/dev/null || killall -q polybar

# --- Auto-detection (using globs over /sys) -------------------------------
first_match() {  # print the basename of the first existing path in the glob
    local p
    for p in "$@"; do [ -e "$p" ] && { basename "$p"; return; }; done
}
# WiFi interface (wl*) and Ethernet (en*/eth*)
WLAN_IFACE="$(first_match /sys/class/net/wl*)"
ETH_IFACE="$(first_match /sys/class/net/en* /sys/class/net/eth*)"
# Battery and adapter
BATTERY="$(first_match /sys/class/power_supply/BAT*)"
ADAPTER="$(first_match /sys/class/power_supply/ADP* /sys/class/power_supply/AC*)"

export WLAN_IFACE="${WLAN_IFACE:-wlan0}"
export ETH_IFACE="${ETH_IFACE:-eth0}"
export BATTERY="${BATTERY:-BAT0}"
export ADAPTER="${ADAPTER:-ADP1}"

# --- Launch bar ----------------------------------------------------------
echo "---" | tee -a /tmp/polybar1.log
polybar --config="$HOME/.config/polybar/config.ini" bar1 2>&1 | tee -a /tmp/polybar1.log & disown

echo "Bars launched (wlan=$WLAN_IFACE eth=$ETH_IFACE bat=$BATTERY)..."
