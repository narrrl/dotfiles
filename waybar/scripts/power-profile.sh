#!/bin/bash

# Script to manage and display system76-power profiles for Waybar

# Define the available power profiles
PROFILES=("Performance" "Balanced" "Battery")

# Get the current power profile
CURRENT_PROFILE=$(system76-power profile | awk '/Power Profile/ {print $3}')

# Function to switch to the next profile
switch_next_profile() {
    # Find the index of the current profile
    for i in "${!PROFILES[@]}"; do
        if [[ "${PROFILES[$i]}" == "$CURRENT_PROFILE" ]]; then
            current_index=$i
            break
        fi
    done

    # Calculate the index of the next profile
    next_index=$(((current_index + 1) % ${#PROFILES[@]}))
    NEXT_PROFILE=${PROFILES[$next_index]}

    # Switch to the next profile
    system76-power profile "$NEXT_PROFILE"
}

# If the script is called with "next", switch the profile
if [[ "$1" == "next" ]]; then
    switch_next_profile
    # After switching, get the new current profile
    CURRENT_PROFILE=$(system76-power profile | awk '/Power Profile/ {print $3}')
fi

# Set an icon based on the current profile
case $CURRENT_PROFILE in
    "Performance")
        ICON="🚀"
        ;;
    "Balanced")
        ICON="⚖️"
        ;;
    "Battery")
        ICON="🔋"
        ;;
    *)
        ICON="❓"
        ;;
esac

# Output in JSON format for Waybar
printf '{"text": "%s", "tooltip": "Power Profile: %s", "class": "%s"}\n' "$ICON" "$CURRENT_PROFILE" "$(echo $CURRENT_PROFILE | tr '[:upper:]' '[:lower:]')"

