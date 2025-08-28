#!/bin/bash
USAGE=$(cat /sys/class/drm/card1/device/gpu_busy_percent)
MEM_USED=$(cat /sys/class/drm/card1/device/mem_info_vram_used)
MEM_TOTAL=$(cat /sys/class/drm/card1/device/mem_info_vram_total)
EDGE_TEMP=$(cat /sys/class/drm/card1/device/hwmon/hwmon2/temp1_input)
JUNC_TEMP=$(cat /sys/class/drm/card1/device/hwmon/hwmon2/temp2_input)
MEM_TEMP=$(cat /sys/class/drm/card1/device/hwmon/hwmon2/temp3_input)
GPU=$(/opt/rocm/bin/rocm-smi --showproductname | grep "Card Series" | awk -F':' '{print $3}' | xargs)
TEXT="$USAGE% $(printf "%.1f" $(echo "scale=2; $MEM_USED/1024/1024/1024" | bc -l))/$(printf "%.1f" $(echo "scale=2; $MEM_TOTAL/1024/1024/1024" | bc -l))GB TEMP: $(printf "%.1f" $(echo "scale=2; $EDGE_TEMP/1000" | bc -l))/$(printf "%.1f" $(echo "scale=2; $JUNC_TEMP/1000" | bc -l))/$(printf "%.1f" $(echo "scale=2; $MEM_TEMP/1000" | bc -l))C"
RATIO=$(echo "$MEM_USED/ $MEM_TOTAL" | bc -l)

CLASS=""

if (( $(echo "$USAGE > 95" | bc -l) )); then
  CLASS="max"
elif (( $(echo "$USAGE > 75" | bc -l) )); then
  CLASS="high"
else
  CLASS="normal"
fi

echo "{\"text\":\"GPU: $TEXT\", \"tooltip\": \"$GPU\", \"class\":\"$CLASS\"}"
