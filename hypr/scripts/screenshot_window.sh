#!/bin/sh

# Get active window info in JSON format
WINDOW_INFO=$(hyprctl activewindow -j)

# Extract window class name (app name)
APP_NAME=$(echo "$WINDOW_INFO" | jq -r '.class')

# If app name is empty, null, or invalid, default to "unknown"
if [ -z "$APP_NAME" ] || [ "$APP_NAME" = "null" ]; then
    APP_NAME="unknown"
fi

# Sanitize app name: convert to lowercase and replace characters that aren't letters, numbers, hyphens, or underscores with underscores
APP_NAME_SAFE=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/_/g')

# Extract geometry: "x,y wxh"
GEOMETRY=$(echo "$WINDOW_INFO" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')

# Check if geometry is valid
if [ -z "$GEOMETRY" ] || [ "$GEOMETRY" = "null,null nullxnull" ]; then
    notify-send -u normal "Screenshot Error" "No active window found to screenshot."
    exit 1
fi

ACTION=$1

case "$ACTION" in
    copy)
        grim -g "$GEOMETRY" - | wl-copy
        notify-send -u low "Screenshot" "Active window ($APP_NAME) copied to clipboard"
        ;;
    save)
        SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
        APP_DIR="$SCREENSHOTS_DIR/$APP_NAME_SAFE"
        mkdir -p "$APP_DIR"
        FILE_NAME="$(date +'%Y-%m-%d_%H-%M-%S').png"
        FILE_PATH="$APP_DIR/$FILE_NAME"
        
        grim -g "$GEOMETRY" "$FILE_PATH"
        notify-send -u low "Screenshot" "Saved active window to $APP_NAME_SAFE/$FILE_NAME"
        ;;
    *)
        echo "Usage: $0 {copy|save}"
        exit 1
        ;;
esac

exit 0
