#!/bin/bash

# --- CONFIGURATION ---
# Your Pixel Buds Pro's MAC Address
MAC_ADDRESS="B4:23:A2:09:D3:53"
# --- END CONFIGURATION ---

# Check if the device is connected using bluetoothctl.
if bluetoothctl info "$MAC_ADDRESS" | grep -q "Connected: yes"; then
    
    # If connected, get battery info from pbpctrl.
    if battery_output=$(pbpctrl show battery); then
        # Use awk to grab the third field, which is the percentage or "unknown".
        left_bud=$(echo "$battery_output" | grep "left bud:" | awk '{print $3}')
        right_bud=$(echo "$battery_output" | grep "right bud:" | awk '{print $3}')

        # If both buds are unknown (e.g., case is closed and buds are out of range),
        # or if the command output is empty, hide the module.
        if ([[ "$left_bud" == "unknown" ]] && [[ "$right_bud" == "unknown" ]]) || \
           [[ -z "$left_bud" && -z "$right_bud" ]]; then
            echo "{}"
            exit 0
        fi

        # Prepare the display string for the left bud.
        if [[ "$left_bud" == "unknown" ]]; then
            left_display="L: ---"
        else
            left_display="L: $left_bud"
        fi

        # Prepare the display string for the right bud.
        if [[ "$right_bud" == "unknown" ]]; then
            right_display="R: ---"
        else
            right_display="R: $right_bud"
        fi
        
        # Format the final output for Waybar as JSON.
        printf '{"text": "%s | %s", "tooltip": "Pixel Buds Pro 2", "class": "connected"}\n' "$left_display" "$right_display"

    else
        # pbpctrl failed to run, so hide the module.
        echo "{}"
    fi
else
    # Not connected, output an empty JSON object to hide the module.
    echo "{}"
fi
