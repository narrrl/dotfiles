#!/bin/bash
SINKS=($(pactl list short sinks | awk '{print $2}'))
CURRENT_SINK=$(pactl info | grep 'Default Sink' | cut -d ' ' -f3)
NUM_SINKS=${#SINKS[@]}

for i in "${!SINKS[@]}"; do
    if [[ "${SINKS[$i]}" == "$CURRENT_SINK" ]]; then
        NEXT_INDEX=$(( (i + 1) % NUM_SINKS ))
        pactl set-default-sink "${SINKS[$NEXT_INDEX]}"
        break
    fi
done
