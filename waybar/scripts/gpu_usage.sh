#!/bin/bash
USAGE=$(cat /sys/class/drm/card1/device/gpu_busy_percent)
MEM_USED=$(cat /sys/class/drm/card1/device/mem_info_vram_used)
MEM_TOTAL=$(cat /sys/class/drm/card1/device/mem_info_vram_total)
GPU=$(/opt/rocm/bin/rocm-smi --showproductname | grep "Card Series" | awk -F':' '{print $3}' | xargs)
TEXT="$USAGE% $(printf "%.2f\n" $(echo "scale=2; $MEM_USED/1024/1024/1024" | bc -l))/$(echo "scale=2; $MEM_TOTAL/1024/1024/1024" | bc -l)GB"
RATIO=$(echo "$MEM_USED/ $MEM_TOTAL" | bc -l)

CLASS=""

if (( $(echo "$USAGE > 95" | bc -l) )); then
  CLASS="max_usage"
elif (( $(echo "$USAGE > 75" | bc -l) )); then
  CLASS="high_usage"
else
  CLASS="normal_usage"
fi

echo "{\"text\":\"GPU: $TEXT\", \"tooltip\": \"$GPU\", \"class\":\"$CLASS\"}"
