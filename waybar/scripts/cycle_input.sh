#!/bin/bash
DEFAULT_SOURCE=$(pactl info | grep 'Default Source' | cut -d ' ' -f3)
DESCRIPTION=$(pactl list sources | grep -A2 "Name: $DEFAULT_SOURCE" | grep "Description:" | cut -d ' ' -f2-)


case $1 in
	cycle)
		SOURCES=($(pactl list short sources | awk '{print $2}'))
		NUM_SOURCES=${#SOURCES[@]}
		CURRENT_SOURCE=$(pactl info | grep 'Default Source' | cut -d ' ' -f3)

		for i in "${!SOURCES[@]}"; do
			if [[ "${SOURCES[$i]}" == "$CURRENT_SOURCE" ]]; then
				NEXT_INDEX=$(( (i + 1) % NUM_SOURCES ))
				pactl set-default-source "${SOURCES[$NEXT_INDEX]}"
				exit 0
			fi
		done
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
		echo "usage audio.sh {cycle|show}"
		;;
esac
