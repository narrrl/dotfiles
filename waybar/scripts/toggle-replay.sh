#!/bin/bash

PID_FILE="/tmp/gpu-screen-recorder.pid"

if [ -f "$PID_FILE" ] && ps -p "$(cat "$PID_FILE")" > /dev/null; then
    $HOME/.config/hypr/scripts/replay-ctrl.sh stop
else
    $HOME/.config/hypr/scripts/replay-ctrl.sh start
fi
