#!/bin/bash

# --- CONFIGURATION ---
# Your Pixel Buds Pro's MAC Address
MAC_ADDRESS="B4:23:A2:09:D3:53"
# --- END CONFIGURATION ---

not_connected() {
    printf '{"text": "L: --- | R: ---", "tooltip": "Pixel Buds Pro 2 not connected", "class": "disconnected"}\n'
	exit 0
}

# This function gets the current status and formats it for Waybar.
get_status() {
	# Get all info from pbpctrl in one go. Redirect errors to null.
	battery_output=$(pbpctrl show battery 2>/dev/null)

	# Fallback: If pbpctrl fails or returns 'unknown', hide the module.
	if [[ $? -ne 0 || -z "$battery_output" ]]; then
		not_connected
	fi

	# --- PARSE BATTERY INFO ---
	left_bud=$(echo "$battery_output" | grep "left bud:" | awk '{print $3}')
	right_bud=$(echo "$battery_output" | grep "right bud:" | awk '{print $3}')

	if ([[ "$left_bud" == "unknown" ]] && [[ "$right_bud" == "unknown" ]]) || \
	   [[ -z "$left_bud" && -z "$right_bud" ]]; then
		echo "{}"
		exit 0
	fi

	if [[ "$left_bud" == "unknown" ]]; then
		left_display="L: ---"
	else
		left_display="L: $left_bud"
	fi

	if [[ "$right_bud" == "unknown" ]]; then
		right_display="R: ---"
	else
		right_display="R: $right_bud"
	fi

	# --- PARSE ANC INFO ---
	current_mode=$(pbpctrl get anc 2>/dev/null)
	
	case "$current_mode" in
		"active")
			anc_icon="ANC"
			class="anc-active"
			;;
		"aware")
			anc_icon="Aware"
			class="anc-aware"
			;;
		"off")
			anc_icon="Off"
			class="anc-off"
			;;
		*)
			anc_icon="?"
			class="anc-unknown"
			;;
	esac

	# --- FORMAT OUTPUT ---
	printf '{"text": "%s | %s | %s", "tooltip": "Pixel Buds Pro 2", "class": "%s"}\n' \
		"$left_display" "$right_display" "$anc_icon" "$class"
}

status() {
	# First, check if the device is connected using bluetoothctl.
	if bluetoothctl info "$MAC_ADDRESS" | grep -q "Connected: yes"; then
		# --- DEVICE IS CONNECTED ---
		get_status
	else
		# --- DEVICE IS NOT CONNECTED ---
		not_connected
	fi
}

# Handle click actions passed from Waybar.
case "$1" in
	cycle_anc)
		current_mode=$(pbpctrl get anc 2>/dev/null)
		next_mode="active"
		case "$current_mode" in
			active)
				next_mode="aware"
				;;
			aware)
				next_mode="off"
				;;
			off)
				next_mode="active"
				;;
		esac
		pbpctrl set anc "$next_mode"
		sleep 0.1
		;;
	connect)
		if bluetoothctl info "$MAC_ADDRESS" | grep -q "Connected: yes"; then
			notify-send "Pixel Buds Pro 2 are already connected"
		else
			bluetoothctl connect "$MAC_ADDRESS" & disown
		fi
		;;
	disconnect)
		if bluetoothctl info "$MAC_ADDRESS" | grep -q "Connected: yes"; then
			bluetoothctl disconnect "$MAC_ADDRESS" & disown
		else
			notify-send "Pixel Buds Pro 2 aren't connected"
		fi
		;;
	*)
		status
		;;
esac
