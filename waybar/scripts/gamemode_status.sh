#!/usr/bin/env sh
HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = 1 ] ; then
    echo '{"text": "Gamemode", "tooltip": "Gamemode deactivated"}'
else
    echo '{"text": "Gamemode", "tooltip": "Gamemode activated", "class": "active"}'
fi
