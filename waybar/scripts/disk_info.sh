#!/bin/sh

if [ -z "$1" ]; then
  echo "Usage: $0 <mountpoint>"
  exit 1
fi

MOUNTPOINT=$1

# Get disk usage info
USED=$(df -h --output=used "$MOUNTPOINT" | sed '1d' | awk '{print $1}')
TOTAL=$(df -h --output=size "$MOUNTPOINT" | sed '1d' | awk '{print $1}')
PERCENTAGE=$(df --output=pcent "$MOUNTPOINT" | sed '1d' | tr -d '%' | awk '{print $1}')

# Set class based on usage
CLASS="normal"
if [ "$PERCENTAGE" -gt 95 ]; then
  CLASS="max"
elif [ "$PERCENTAGE" -gt 80 ]; then
  CLASS="high"
fi

# Create tooltip with more details
TOOLTIP=$(df -h "$MOUNTPOINT" | sed '1d' | awk '{printf "Used: %s\nTotal: %s\nFree: %s", $3, $2, $4}')

# Output JSON for Waybar using jq
jq -n -c \
  --arg text "$1 $USED/$TOTAL" \
  --arg tooltip "$TOOLTIP" \
  --arg class "$CLASS" \
  '{"text": $text, "tooltip": $tooltip, "class": $class}'
