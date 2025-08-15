#!/bin/bash

PID_FILE="/tmp/gpu-screen-recorder.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null; then
        echo '{"text": "Replay", "tooltip": "Replay running", "class": "recording"}'
    else
        # The process is not running, but the PID file exists.
        # This can happen if the process crashed.
        # We'll remove the stale PID file.
        rm "$PID_FILE"
    	echo '{"text": "Replay", "tooltip": "Replay paused"}'
    fi
else
    echo '{"text": "Replay", "tooltip": "Replay paused"}'
fi
