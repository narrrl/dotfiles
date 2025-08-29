#!/bin/bash

# Path for the temporary file to store previous stats
STATS_FILE="/tmp/waybar_net_stats"

# Find the default network interface
INTERFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)

# Exit if no active interface is found
if [ -z "$INTERFACE" ]; then
    echo "{\"text\": \"No connection\"}"
    exit 0
fi

# Get the IP address for the interface
IP_ADDR=$(ip -4 addr show "$INTERFACE" | grep -oP 'inet \K[\d.]+')

# Get current time and byte counts
TIME_NOW=$(date +%s)
RX_BYTES_NOW=$(cat "/sys/class/net/$INTERFACE/statistics/rx_bytes")
TX_BYTES_NOW=$(cat "/sys/class/net/$INTERFACE/statistics/tx_bytes")

# Initialize speeds to 0
RX_MBPS="0.00"
TX_MBPS="0.00"

# Read previous values if the stats file exists
if [ -f "$STATS_FILE" ]; then
    source "$STATS_FILE" # This loads PREV_TIME, PREV_RX_BYTES, PREV_TX_BYTES
fi

# Calculate speed if we have previous data and time has passed
if [ -n "$PREV_TIME" ] && [ "$TIME_NOW" -gt "$PREV_TIME" ]; then
    TIME_DIFF=$((TIME_NOW - PREV_TIME))

    RX_BPS=$(( (RX_BYTES_NOW - PREV_RX_BYTES) / TIME_DIFF ))
    TX_BPS=$(( (TX_BYTES_NOW - PREV_TX_BYTES) / TIME_DIFF ))

    # Using printf for better formatting (forces two decimal places)
    RX_MBPS=$(printf "%.2f" "$(echo "$RX_BPS / 1024 / 1024" | bc -l)")
    TX_MBPS=$(printf "%.2f" "$(echo "$TX_BPS / 1024 / 1024" | bc -l)")
fi

# Save current values for the next run
echo "PREV_TIME=$TIME_NOW" > "$STATS_FILE"
echo "PREV_RX_BYTES=$RX_BYTES_NOW" >> "$STATS_FILE"
echo "PREV_TX_BYTES=$TX_BYTES_NOW" >> "$STATS_FILE"

# Output JSON for Waybar
echo "{\"text\": \"$INTERFACE ($IP_ADDR):  ${RX_MBPS} MB/s   ${TX_MBPS} MB/s\"}"
