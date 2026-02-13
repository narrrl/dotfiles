#!/bin/bash
DEFAULT_SOURCE=$(pactl info | grep 'Default Source' | cut -d ' ' -f3)
DESCRIPTION=$(pactl list sources | grep -A2 "Name: $DEFAULT_SOURCE" | grep "Description:" | cut -d ' ' -f2-)


case $1 in
	cycle)
		# Filter out monitor sources
		SOURCES=($(pactl list short sources | awk '{print $2}' | grep -v ".monitor"))
		NUM_SOURCES=${#SOURCES[@]}
		CURRENT_SOURCE=$(pactl info | grep 'Default Source' | cut -d ' ' -f3)

		for i in "${!SOURCES[@]}"; do
			if [[ "${SOURCES[$i]}" == "$CURRENT_SOURCE" ]]; then
				NEXT_INDEX=$(( (i + 1) % NUM_SOURCES ))
				pactl set-default-source "${SOURCES[$NEXT_INDEX]}"
				exit 0
			fi
		done
		# If current source was a monitor or not in list, just pick the first one
		if [ $NUM_SOURCES -gt 0 ]; then
			pactl set-default-source "${SOURCES[0]}"
		fi
		;;
	show)
		TEXT=$(echo "$DESCRIPTION" | cut -c -20)
		if [ -z "$DESCRIPTION" ]; then
			DESCRIPTION=$DEFAULT_SOURCE
		fi
		CLASS="" 
		case $(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}') in
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
		echo "usage cycle_input.sh {cycle|show}"
		;;
esac
