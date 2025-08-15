#!/bin/sh

PROGRAM_NAME="gpu-screen-recorder"
PID_FILE="/tmp/gpu-screen-recorder.pid"

start() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null; then
            notify-send -u low "$PROGRAM_NAME" "$PROGRAM_NAME is already active."
            exit 0
        fi
    fi

    video_path="$HOME/Videos/replay/"
    mkdir -p "$video_path"
    notify-send -u low "$PROGRAM_NAME" "$PROGRAM_NAME is starting ..."
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
		-k av1_10bit \
		-q high \
		-r 120 \
		-replay-storage ram \
		-ab 320 \
		-cursor yes \
		-sc "$HOME/.config/hypr/scripts/replay-notification.sh" \
		-o "$video_path" &> /dev/null &
	echo $! > "$PID_FILE"
}

stop() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null; then
            kill "$PID"
            rm "$PID_FILE"
            notify-send -u low "$PROGRAM_NAME" "$PROGRAM_NAME has been stopped."
        else
            rm "$PID_FILE" # Stale PID file
            notify-send -u low "$PROGRAM_NAME" "$PROGRAM_NAME is not running."
        fi
    else
        notify-send -u low "$PROGRAM_NAME" "$PROGRAM_NAME is not running."
    fi
}

toggle() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null; then
			stop
        else
            rm "$PID_FILE" # Stale PID file
			start
        fi
    else
		start
    fi
}

save() {
	if [ -f "$PID_FILE" ]; then
		PID=$(cat "$PID_FILE")
		if ps -p "$PID" > /dev/null; then
			pkill -SIGUSR1 -f gpu-screen-recorder
		else
			# The process is not running, but the PID file exists.
			# This can happen if the process crashed.
			# We'll remove the stale PID file.
			rm "$PID_FILE"
			notify-send -u low "$PROGRAM_NAME" "$PROGRAM_NAME is not running."
		fi
	else
		notify-send -u low "$PROGRAM_NAME" "$PROGRAM_NAME is not running."
	fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
	save)
		save
		;;
	toggle)
		toggle
		;;
    *)
        echo "Usage: $0 {start|stop|save}"
        exit 1
esac

exit 0
