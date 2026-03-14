#!/bin/bash
# ~/.config/hypr/scripts/lid_handler.sh

# The file that tells Hyprland to keep the lid off during reloads
LID_STATE_FILE="$HOME/.config/hypr/lid_state.conf"

restart_ui() {
    # Spawn in background and detach
	systemctl restart --user waybar hyprpaper
}

if [[ "$1" == "close" ]]; then
    # Check if ANY external monitor is connected and active
    if hyprctl monitors all | grep -qE "Monitor (DP|HDMI|Type-C)-"; then
        
        # Prevent laptop screen from turning on during manual config reloads
        echo "monitor=eDP-1, disable" > "$LID_STATE_FILE"
        
        # Extract the CURRENT live settings of all external monitors using jq
        # This grabs the active resolution, refresh rate, position, and scale.
        LIVE_MONITORS=$(hyprctl -j monitors | jq -c '.[] | select(.name != "eDP-1")')
        
        # 3. Disable the laptop screen
        hyprctl keyword monitor "eDP-1, disable"
        
        # 4. Re-apply the live settings to external monitors so they don't reset
        echo "$LIVE_MONITORS" | while read -r mon_json; do
            NAME=$(echo "$mon_json" | jq -r '.name')
            WIDTH=$(echo "$mon_json" | jq -r '.width')
            HEIGHT=$(echo "$mon_json" | jq -r '.height')
            REFRESH=$(echo "$mon_json" | jq -r '.refreshRate')
            X=$(echo "$mon_json" | jq -r '.x')
            Y=$(echo "$mon_json" | jq -r '.y')
            SCALE=$(echo "$mon_json" | jq -r '.scale')
            
            # Formats it exactly as Hyprland expects: DP-1, 1920x1080@240, 0x0, 1
            hyprctl keyword monitor "$NAME, ${WIDTH}x${HEIGHT}@${REFRESH}, ${X}x${Y}, $SCALE"
        done
        
		# restart ui
        restart_ui
    fi

elif [[ "$1" == "open" ]]; then
    # Clear the override file so the laptop screen is allowed to turn on again
    echo "" > "$LID_STATE_FILE"
    
    # Let Hyprland reload itself. 
    # This automatically re-enables eDP-1 based on your hardcoded hyprland.conf!
    hyprctl reload
    
    restart_ui
fi
