#!/bin/bash
export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/hypr/ 2>/dev/null | head -1)

STATE_FILE="/tmp/hypr-floating-mode-$(id -u)"

if [ -f "$STATE_FILE" ]; then
    # Currently in floating mode → switch to tiling
    rm "$STATE_FILE"
    hyprctl keyword windowrule "float, class:.+" >/dev/null
    # Set all current floating windows to tiled
    hyprctl clients -j | jq -r '.[] | select(.floating==true) | .address' | \
        while read addr; do
            hyprctl dispatch settiled address:$addr
        done
    notify-send "Hyprland" "Tiling mode" 2>/dev/null
else
    # In tiling mode → change to floating
    touch "$STATE_FILE"
    hyprctl keyword windowrule "float, class:.+"
    # Flot all current tiled windows
    hyprctl clients -j | jq -r '.[] | select(.floating==false) | .address' | \
        while read addr; do
            hyprctl dispatch togglefloating address:$addr
        done
    notify-send "Hyprland" "Floating mode" 2>/dev/null
fi
