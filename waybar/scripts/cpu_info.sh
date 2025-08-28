#!/bin/bash
USAGE=$(mpstat 1 1 | awk '/Average:/ {print 100 - $12}')
TEMP=$(cat /sys/class/hwmon/hwmon6/temp1_input)
TEXT="$(printf "%.1f" $(echo "$USAGE"))% TEMP: $(printf "%.1f" $(echo "scale=2; $TEMP"/1000 | bc -l))C"
CPU=$(lscpu | grep 'Model name' | awk -F': ' '{print $2}' | sed 's/^[ \t]*//')
TOOLTIP=$(ps -eo %cpu,comm --sort=-%cpu | head -n 6 | sed '1d' | awk -v ncores=$(nproc) '{printf "%.1f%%\t%s\\n", $1/ncores, $2}')

CLASS=""

if (( $(echo "$USAGE > 95" | bc -l) )); then
  CLASS="max"
elif (( $(echo "$USAGE > 75" | bc -l) )); then
  CLASS="high"
else
  CLASS="normal"
fi

echo "{\"text\":\"CPU: $TEXT\", \"tooltip\": \"$TOOLTIP\", \"class\":\"$CLASS\"}"
