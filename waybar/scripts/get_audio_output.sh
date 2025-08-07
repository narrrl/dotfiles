#!/bin/bash
DEFAULT_SINK=$(pactl info | grep 'Default Sink' | cut -d ' ' -f3)
DESCRIPTION=$(pactl list sinks | grep -A2 "Name: $DEFAULT_SINK" | grep "Description:" | cut -d ' ' -f2-)

if [ -z "$DESCRIPTION" ]; then
    DESCRIPTION=$DEFAULT_SINK
fi

TEXT=$(echo "$DESCRIPTION" | cut -c -20)

printf '{"text": "%s", "tooltip": "%s"}
' "$TEXT" "$DESCRIPTION"
