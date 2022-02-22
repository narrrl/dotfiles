#!/usr/bin/env bash

# Add this script to your wm startup file.

DIR="$HOME/.config/polybar"

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
# while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar --config=$DIR/config.ini -q workspaces &
polybar --config=$DIR/config.ini -q workspaces2 &
polybar --config=$DIR/config.ini -q systeminfo &
polybar --config=$DIR/config.ini -q applications &
polybar --config=$DIR/config.ini -q topinfo &
polybar --config=$DIR/config.ini -q player &
# polybar --config=$DIR/config.ini -q spotifycontrolbar &
# polybar --config=$DIR/config.ini -q tray &
