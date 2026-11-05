#!/bin/sh
# Screen recording as a toggle: the first press picks an area and starts
# wf-recorder, the next press stops it and answers with a notification that
# opens the file or its folder.
#
#   record.sh region    pick an area (the default)
#   record.sh screen    the focused monitor
#
# Recordings land in ~/Videos/Recordings. Cancelling the picker does nothing.

set -eu

dir="$HOME/Videos/Recordings"
pidfile="${XDG_RUNTIME_DIR:-/tmp}/record.pid"
lastfile="${XDG_RUNTIME_DIR:-/tmp}/record.last"

if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
    # SIGINT lets wf-recorder finish the container instead of leaving a
    # truncated file.
    kill -INT "$(cat "$pidfile")"
    while kill -0 "$(cat "$pidfile")" 2>/dev/null; do sleep 0.1; done
    rm -f "$pidfile"
    file=$(cat "$lastfile")
    (
        choice=$(notify-send -a Recorder --action=open=Open --action=folder=Folder \
            "Recording saved" "${file#"$HOME"/}") || exit 0
        case "$choice" in
            open) xdg-open "$file" ;;
            folder) xdg-open "$dir" ;;
        esac
    ) >/dev/null 2>&1 &
    exit 0
fi

case "${1:-region}" in
    region)
        geometry=$(slurp) || exit 0
        set -- -g "$geometry"
        ;;
    screen)
        output=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
        set -- -o "$output"
        ;;
    *)
        echo "usage: record.sh region|screen" >&2
        exit 2
        ;;
esac

mkdir -p "$dir"
file="$dir/$(date +'%Y-%m-%d_%H-%M-%S').mp4"
printf '%s\n' "$file" > "$lastfile"

wf-recorder "$@" -f "$file" >/dev/null 2>&1 &
echo $! > "$pidfile"
notify-send -a Recorder -t 2000 "Recording" "Press the same keys again to stop."
