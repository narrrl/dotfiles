#!/usr/bin/env bash

# Add this script to your wm startup file.

DIR="$HOME/.config/polybar"

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch the bar
wal -n -R
# polybar -q redirect-top &
# polybar -q redirect-bottom &
polybar -q workspaces &
polybar -q systeminfo &
polybar -q applications &
polybar -q topinfo &
polybar -q spotifybar &
