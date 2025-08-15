#!/bin/bash

# --- Configuration ---
CRITICAL_THRESHOLD=15
WARNING_THRESHOLD=50
# ---------------------

# Get the battery path from upower
battery_path=$(upower -e | grep 'BAT')

# Handle case where no battery is found
if [ -z "$battery_path" ]; then
    # Check if we are on AC power anyway
    if [[ $(tlp-stat -s | grep "Power source" | awk '{print $4}') == "AC" ]]; then
        printf '{"text": "", "tooltip": "AC Power (No Battery)", "class": "ac"}\n'
    else
        printf '{"text": "", "tooltip": "Error: Battery not found", "class": "unknown"}\n'
    fi
    exit 0
fi

# Get battery percentage and state
percentage=$(upower -i "$battery_path" | grep "percentage" | awk '{print $2}' | tr -d '%')
state=$(upower -i "$battery_path" | grep "state" | awk '{print $2}')
tlp_profile=$(tlp-stat -s | grep "Power source" | awk '{print $4}')

# Set icon, class, and tooltip based on state and percentage
if [ "$state" == "charging" ] || [ "$tlp_profile" == "AC" ]; then
    icon=""
    class="charging"
    tooltip="TLP: AC | Charging at ${percentage}%"
elif [ "$state" == "discharging" ]; then
    tooltip="TLP: Battery | Discharging at ${percentage}%"
    if [ "$percentage" -le "$CRITICAL_THRESHOLD" ]; then
        icon="" # Very low
        class="critical"
    elif [ "$percentage" -le "$WARNING_THRESHOLD" ]; then
        icon="" # Low
        class="warning"
    elif [ "$percentage" -le 85 ]; then
        icon="" # Healthy
        class="bat"
    else
        icon="" # Full
        class="bat"
    fi
else # Fallback for "fully-charged", "pending-charge", etc.
    icon=""
    class="charging"
    tooltip="TLP: AC | Fully Charged at ${percentage}%"
fi

# Output JSON for Waybar
printf '{"text": "%s%%  %s", "tooltip": "%s", "class": "%s"}\n' "$percentage" "$icon" "$tooltip" "$class"
