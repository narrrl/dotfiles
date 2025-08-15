#!/bin/bash

bt-audio-info() {
	# Check if a MAC address was provided as the first argument.
	if [ -z "$1" ]; then
		echo "Usage: $0 <MAC_ADDRESS>"
		echo "Example: $0 00:11:22:33:AA:BB"
		exit 1
	fi
	MAC_ADDRESS="$1"

	# --- Main Logic ---

	# Construct the PipeWire sink name from the MAC address.
	# The format is typically: bluez_output.XX_XX_XX_XX_XX_XX.a2dp_sink
	# We replace colons with underscores for the format.
	SINK_IDENTIFIER="bluez_output.$(echo "$MAC_ADDRESS" | tr ':' '_')"

	# Use pactl to get the full details for all sinks, then find the one
	# that contains our device's identifier. We use awk to print the
	# entire block of text for that specific sink.
	# We check for a partial match on the sink identifier because the profile
	# (e.g., .a2dp_sink) can change.
	sink_info=$(pactl list sinks | awk -v id="$SINK_IDENTIFIER" '/Sink #/ {p=0} $0 ~ "Name: " id {p=1} p')

	# If sink_info is empty, the device might not be an audio sink or isn't connected.
	if [ -z "$sink_info" ]; then
		echo "Error: Could not find an active audio sink for MAC ${MAC_ADDRESS}"
		echo "Please ensure the device is connected and is an audio output device."
		exit 1
	fi

	# Get the full block of info for the device from bluetoothctl.
	device_info=$(bluetoothctl info "$MAC_ADDRESS")

	# --- Parse Information ---

	# Parse bluetoothctl output for general device details.
	alias=$(echo "$device_info" | rg "Alias:" | cut -d ' ' -f 2-)
	trusted=$(echo "$device_info" | rg "Trusted:" | awk '{print $2}')
	battery_raw=$(echo "$device_info" | rg "Battery Percentage:" | awk -F'[()]' '{print $2}')

	# Parse pactl output for audio-specific details.
	volume=$(echo "$sink_info" | rg "Volume:" | head -n1 | awk '{print $5}')
	codec=$(echo "$sink_info" | rg -e 'bluetooth.codec|api.bluez5.codec' | awk -F'"' '{print $2}')

	# --- Build and Display Compact Output ---

	# Build the output string with all the information.
	output_string="${alias} | MAC: ${MAC_ADDRESS}\n"
	output_string+="Trusted: ${trusted}"

	# Append battery info if available, otherwise show N/A.
	if [ -n "$battery_raw" ]; then
		output_string+=" | Bat: ${battery_raw}%"
	else
		output_string+=" | Bat: N/A"
	fi

	output_string+=" | Vol: ${volume} | Codec: ${codec:-N/A}"

	# Print the final, single-line string.
	echo "$output_string"
}

# Find the MAC address of the first connected device that is an audio sink
find_audio_device() {
	default_sink_name=$(pactl get-default-sink)

	# Check if the default sink is a Bluetooth device. Their names typically
	# start with "bluez_output.". If not, print a message and exit.
	if [[ "$default_sink_name" == bluez_output* ]]; then
		# Extract the MAC address from the sink name.
		# The format is bluez_output.XX_XX_XX_XX_XX_XX.profile
		# We extract the middle part and replace underscores with colons.
		mac_with_underscores=$(echo "$default_sink_name" | cut -d '.' -f 2)
		mac=$(echo "$mac_with_underscores" | tr '_' ':')
		echo "$mac"
		return
	fi

	# else look for the first bluetooth device that provides a sink
	bluetoothctl devices Connected | rg '^Device ' | awk '{print $2}' | while read -r mac;
	do
		# Check if the device provides the "Audio Sink" service
		if bluetoothctl info "$mac" | rg -q "0000110b-0000-1000-8000-00805f9b34fb"; then
			echo "$mac"
			# If you only want the first audio device found, you can 'break' or 'exit' here.
			break 
		fi
	done
}

# If the script is called with "disconnect"
if [ "$1" == "disconnect" ]; then
    device_mac=$(find_audio_device)
    if [ -n "$device_mac" ]; then
        bluetoothctl disconnect "$device_mac"
    fi
	echo "{}"
	exit 0
fi

# Main logic to display the device name
device_mac=$(find_audio_device)

if [ -n "$device_mac" ]; then
    # Get the device alias (name)
    device_name=$(bluetoothctl info "$device_mac" | rg "Alias:" | cut -d ' ' -f 2-)
    # Output in Waybar's JSON format
	tooltip=$(bt-audio-info $device_mac)
    echo "{\"text\": \"$device_name  <span size='large'>󰂰</span>\", \"tooltip\": \"$tooltip\"}"
else
    # Output empty string when no device is connected
    echo "{}"
fi


