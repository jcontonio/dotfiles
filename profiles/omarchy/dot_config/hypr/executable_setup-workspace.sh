#!/bin/bash
# ~/.config/hypr/fix-workspaces.sh

MONITOR=$(hyprctl monitors -j | jq -r '.[].description' | grep -i "arzopa")

sleep 3
hyprctl dispatch workspace 4
hyprctl dispatch moveworkspacetomonitor "4 desc:$MONITOR"
hyprctl dispatch workspace 5
hyprctl dispatch moveworkspacetomonitor "5 desc:$MONITOR"
