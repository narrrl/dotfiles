#!/bin/sh

PROGRAM_NAME="gpu-screen-recorder"

case "$2" in
	replay)
		notify-send -u low "$PROGRAM_NAME" "Replay saved: $1"
		;;
	regular)
		notify-send -u low "$PROGRAM_NAME" "Stream/Video saved: $1"
		;;
	*)
		echo "Usage: $0 {saved_file} {replay|regular}"
		exit 1
esac

exit 0
