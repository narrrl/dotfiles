#!/bin/sh

PROGRAM_NAME="droidcam-cli"
PID_FILE="/tmp/droidcam.pid"
ANDROID_SERIAL=988e5035584a354b4430

start() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null; then
            notify-send -u low "$PROGRAM_NAME" "$PROGRAM_NAME is already active."
            exit 0
        fi
    fi
    notify-send -u low "$PROGRAM_NAME" "$PROGRAM_NAME is starting ..."

 	ANDROID_SERIAL=$ANDROID_SERIAL droidcam-cli -a -v -size=1920x1080 adb 4747 &> /dev/null &
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


case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
	toggle)
		toggle
		;;
    *)
        echo "Usage: $0 {start|stop|save}"
        exit 1
esac

exit 0
