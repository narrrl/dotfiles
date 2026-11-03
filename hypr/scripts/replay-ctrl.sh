#!/bin/sh
# Replay buffer: gpu-screen-recorder keeps the last two minutes of the screen
# and audio in RAM, and `save` writes them out to ~/Videos/replay.
#
#   replay-ctrl.sh toggle    start or stop the buffer       (ALT+Z)
#   replay-ctrl.sh save      write out the last two minutes (ALT+SHIFT+Z)
#   replay-ctrl.sh start|stop
#
# HEVC because this machine's Radeon (Vega 10) has no AV1 encoder; gsr would
# otherwise fall back to h264. Saved clips are announced by
# replay-notification.sh.

APP="Replay"
PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/gpu-screen-recorder.pid"
DIR="$HOME/Videos/replay"

running() {
    [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

start() {
    if running; then
        notify-send -a "$APP" -u low "Replay" "Already buffering."
        return
    fi
    mkdir -p "$DIR"
    gpu-screen-recorder \
        -w screen \
        -f 60 \
        -a default_output -a default_input \
        -fm vfr \
        -c mkv \
        -encoder gpu \
        -bm qp \
        -cr full \
        -tune quality \
        -k hevc \
        -q high \
        -r 120 \
        -replay-storage ram \
        -ab 320 \
        -cursor yes \
        -sc "$HOME/.config/hypr/scripts/replay-notification.sh" \
        -o "$DIR" >/dev/null 2>&1 &
    echo $! > "$PID_FILE"
    notify-send -a "$APP" -u low "Replay on" "Keeping the last two minutes. ALT+SHIFT+Z saves them."
}

stop() {
    if running; then
        kill -INT "$(cat "$PID_FILE")"
        notify-send -a "$APP" -u low "Replay off" "The buffer is gone."
    else
        notify-send -a "$APP" -u low "Replay" "Not running."
    fi
    rm -f "$PID_FILE"
}

save() {
    if running; then
        kill -USR1 "$(cat "$PID_FILE")"
    else
        rm -f "$PID_FILE"
        notify-send -a "$APP" -u low "Replay" "Not running. ALT+Z starts it."
    fi
}

case "$1" in
    start) start ;;
    stop) stop ;;
    save) save ;;
    toggle) if running; then stop; else start; fi ;;
    *)
        echo "usage: $0 start|stop|toggle|save" >&2
        exit 2
        ;;
esac
