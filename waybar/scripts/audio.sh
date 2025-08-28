#!/bin/bash
DEFAULT_SINK=$(pactl info | grep 'Default Sink' | cut -d ' ' -f3)
DESCRIPTION=$(pactl list sinks | grep -A2 "Name: $DEFAULT_SINK" | grep "Description:" | cut -d ' ' -f2-)


case $1 in
	cycle)
		SINKS=($(pactl list short sinks | awk '{print $2}'))
		NUM_SINKS=${#SINKS[@]}
		CURRENT_SINK=$(pactl info | grep 'Default Sink' | cut -d ' ' -f3)

		for i in "${!SINKS[@]}"; do
			if [[ "${SINKS[$i]}" == "$CURRENT_SINK" ]]; then
				NEXT_INDEX=$(( (i + 1) % NUM_SINKS ))
				pactl set-default-sink "${SINKS[$NEXT_INDEX]}"
				exit 0
			fi
		done
		;;
	show)
		TEXT=$(echo "$DESCRIPTION" | cut -c -20)
		if [ -z "$DESCRIPTION" ]; then
			DESCRIPTION=$DEFAULT_SINK
		fi
		CLASS="" 
		case $(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}') in
			yes)
				CLASS="muted"
				;;
			no)
				CLASS="unmuted"
				;;
		esac

		printf '{"text": "%s", "tooltip": "%s", "class": "%s"}' "$TEXT" "$DESCRIPTION" "$CLASS"
		;;
	*)
		echo "usage audio.sh {cycle|show}"
		;;
esac
