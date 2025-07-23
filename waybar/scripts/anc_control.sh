#!/bin/bash

# --- CONFIGURATION ---
# Your Pixel Buds Pro's MAC Address
MAC_ADDRESS="B4:23:A2:09:D3:53"
# --- END CONFIGURATION ---

# First, check if the device is connected using bluetoothctl.
if bluetoothctl info "$MAC_ADDRESS" | grep -q "Connected: yes"; then
    # --- DEVICE IS CONNECTED ---

    # This function gets the current ANC status and formats it for Waybar.
    get_status() {
        # Get the mode from pbpctrl. Redirect errors to null in case of a temporary glitch.
        current_mode=$(pbpctrl get anc 2>/dev/null)

        # Fallback: If pbpctrl fails or returns 'unknown', hide the module.
        # This handles cases where buds are connected but not fully ready.
        if [[ $? -ne 0 || "$current_mode" == "unknown (0)"* || -z "$current_mode" ]]; then
            echo "{}"
            exit 0
        fi

        # Set icon and tooltip based on the current mode.
        case "$current_mode" in
            "active")
                icon="ANC: Active"
                class="anc-active"
                ;;
            "aware")
                icon="ANC: Aware"
                class="anc-aware"
                ;;
            "off")
                icon="ANC: Off"
                class="anc-off"
                ;;
            *)
                # Failsafe to hide the module if the mode is unrecognized.
                echo "{}"
                exit 0
                ;;
        esac
        echo "{\"text\":\"$icon\", \"class\":\"$class\"}"
    }

    # Handle click actions passed from Waybar.
    case "$1" in
        # Right-click: Cycle between active and aware modes.
        cycle)
            current_mode=$(pbpctrl get anc 2>/dev/null)
            if [[ "$current_mode" == "active" ]]; then
                pbpctrl set anc aware
            else
                pbpctrl set anc active
            fi
            sleep 0.1 # Brief pause for the state to update.
            ;;
        # Left-click: Turn ANC off.
        off)
            pbpctrl set anc off
            sleep 0.1 # Brief pause for the state to update.
            ;;
    esac

    # Always display the current status after any action or on a scheduled interval.
    get_status

else
    # --- DEVICE IS NOT CONNECTED ---
    # Output an empty JSON object to completely hide the Waybar module.
    echo "{}"
fi
