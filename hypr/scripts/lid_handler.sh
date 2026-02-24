#!/bin/bash
# ~/.config/hypr/scripts/lid_handler.sh

if [[ "$1" == "close" ]]; then
    # Lid closed: disable laptop screen if any DP-* monitor is present
    # Using 'all' to detect monitors even if they are currently disabled
    if hyprctl monitors all | grep -q "Monitor DP-"; then
        hyprctl keyword monitor "eDP-1, disable" # Disable laptop display
        
        # Enable all detected DP-* monitors
        for monitor in $(hyprctl monitors all | grep "Monitor DP-" | awk '{print $2}'); do
            hyprctl keyword monitor "$monitor, enable"
        done
		systemd-run --user --on-active=5s systemctl --user restart waybar.service hyprpaper.service
    fi
elif [[ "$1" == "open" ]]; then
    # Lid opened: re-enable laptop screen
    hyprctl keyword monitor "eDP-1, enable"
fi
