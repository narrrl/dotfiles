#!/bin/sh

TOOLTIP=$(ps -eo rss,comm --sort=-rss | head -n 6 | sed '1d' | awk '{output = output sprintf("%.2f GB\t%s\\n", $1/1024/1024, $2)} END {printf "%s", output}')
TOTAL=$(awk '/MemTotal/ {printf "%.2f\n", $2/1024/1024}' /proc/meminfo)
USED=$(awk '/MemTotal/ {total=$2} /MemAvailable/ {available=$2} END {printf "%.2f\n", (total-available)/1024/1024}' /proc/meminfo)
RATIO=$(echo "$USED/ $TOTAL" | bc -l)

CLASS=""

if (( $(echo "$RATIO> 95" | bc -l) )); then
  CLASS="max"
elif (( $(echo "$RATIO> 75" | bc -l) )); then
  CLASS="high"
else
  CLASS="normal"
fi

printf '{"text": "MEM: %s/%sGB", "tooltip": "%s", "class": "%s"}' "$USED" "$TOTAL" "$TOOLTIP" "$CLASS"
