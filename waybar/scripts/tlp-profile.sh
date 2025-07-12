#!/bin/bash

# Get the current power source from tlp-stat
power_source=$(tlp-stat -s | grep -i "power source" | awk '{print $4}')

if [ "$power_source" == "AC" ]; then
    # On AC power
    icon=""
    tooltip="TLP Profile: AC"
    class="ac"
elif [ "$power_source" == "battery" ]; then
    # On Battery power
    icon=""
    tooltip="TLP Profile: Battery"
    class="bat"
else
    # Fallback for unknown state
    icon=""
    tooltip="TLP Profile: Unknown"
    class="unknown"
fi

# Output in JSON format for Waybar
printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$icon" "$tooltip" "$class" 
