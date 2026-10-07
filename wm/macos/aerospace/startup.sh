#!/usr/bin/env bash
# Login layout: Brave on 1, Warp on 2, Claude on 3, VS Code on 4, then back to 1.
# Brave, Claude and VS Code always go to their workspace (on-window-detected).
# Warp only goes to 2 here, so new terminals open where you are; its first
# window is waited for, as it can take a while after login.
aerospace=/opt/homebrew/bin/aerospace

open -a "Brave Browser"
open -a Warp
open -a Claude
open -a "Visual Studio Code"

for _ in $(seq 1 90); do
    warp="$("$aerospace" list-windows --monitor all --app-bundle-id dev.warp.Warp-Stable --format '%{window-id}' | head -1)"
    [[ -n "$warp" ]] && break
    sleep 1
done
[[ -n "$warp" ]] && "$aerospace" move-node-to-workspace --window-id "$warp" 2
sleep 3
"$aerospace" workspace 1
