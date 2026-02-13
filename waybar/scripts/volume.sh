#!/bin/bash

TYPE=$1 # "mic" for source, empty for sink

if [ "$TYPE" == "mic" ]; then
    TARGET="@DEFAULT_AUDIO_SOURCE@"
else
    TARGET="@DEFAULT_AUDIO_SINK@"
fi

# Get volume and mute status from wpctl
OUTPUT=$(wpctl get-volume $TARGET)
VOLUME_RAW=$(echo "$OUTPUT" | awk '{print $2}')
VOLUME=$(echo "$VOLUME_RAW * 100 / 1" | bc)
MUTE=$(echo "$OUTPUT" | grep -c "MUTED")

if [ "$MUTE" -eq 1 ]; then
    if [ "$TYPE" == "mic" ]; then
        ICON=""
    else
        ICON=""
    fi
    printf '{"text": "%s", "class": "muted", "percentage": %d}' "$ICON" "$VOLUME"
else
    if [ "$TYPE" == "mic" ]; then
        ICON=""
    else
        if [ "$VOLUME" -le 30 ]; then
            ICON=""
        elif [ "$VOLUME" -le 60 ]; then
            ICON=""
        else
            ICON=""
        fi
    fi
    printf '{"text": "%d%% %s", "class": "unmuted", "percentage": %d}' "$VOLUME" "$ICON" "$VOLUME"
fi
