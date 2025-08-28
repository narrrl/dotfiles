#!/bin/bash

PID_FILE="/tmp/gpu-screen-recorder.pid"
FORMAT_RECORDING="<span size='large'></span>"
FORMAT_STOPPED="<span size='large'></span>"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null; then
        echo "{\"text\": \"$FORMAT_RECORDING\", \"tooltip\": \"Replay running\", \"class\": \"recording\"}"
    else
        # The process is not running, but the PID file exists.
        # This can happen if the process crashed.
        # We'll remove the stale PID file.
        rm "$PID_FILE"
    	echo "{\"text\": \"$FORMAT_STOPPED\", \"tooltip\": \"Replay paused\"}"
    fi
else
	echo "{\"text\": \"$FORMAT_STOPPED\", \"tooltip\": \"Replay paused\"}"
fi
