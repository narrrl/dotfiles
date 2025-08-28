#!/usr/bin/env sh

FORMAT_ACTIVATED="<span size='large'>󰊖</span>"
FORMAT_DEACTIVATED="<span size='large'></span>"
HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = 1 ] ; then
    printf "{\"text\": \"$FORMAT_DEACTIVATED\", \"tooltip\": \"Gamemode deactivated\"}"
else
	printf "{\"text\": \"$FORMAT_ACTIVATED\", \"tooltip\": \"Gamemode activated\", \"class\": \"active\"}"
fi
