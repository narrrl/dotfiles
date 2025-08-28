#!/bin/bash

# Get BTRFS filesystems
btrfs_filesystems=$(df -hT | grep btrfs)

# Initialize variables
total_used=0
total_size=0

# Process each BTRFS filesystem
while read -r line; do
  size_str=$(echo "$line" | awk '{print $3}')
  used_str=$(echo "$line" | awk '{print $4}')

  size=$(echo "$size_str" | sed 's/[GT]//')
  used=$(echo "$used_str" | sed 's/[GT]//')

  if [[ $size_str == *T ]]; then
    size=$(awk -v s="$size" 'BEGIN {print s*1024}')
  fi
  if [[ $used_str == *T ]]; then
    used=$(awk -v u="$used" 'BEGIN {print u*1024}')
  fi

  total_size=$(awk -v total="$total_size" -v size="$size" 'BEGIN {print total+size}')
  total_used=$(awk -v total="$total_used" -v used="$used" 'BEGIN {print total+used}')

done <<< "$btrfs_filesystems"

# Calculate usage percentage
usage_percentage=$(awk -v used="$total_used" -v total="$total_size" 'BEGIN {printf "%.0f", (used/total)*100}')

# Set class based on usage
if [ "$usage_percentage" -gt 95 ]; then
  class="max"
elif [ "$usage_percentage" -gt 80 ]; then
  class="high"
else
  class="normal"
fi

text="$(printf "%.0f" $total_used)G / $(printf "%.0f" $total_size)G"

# Manually construct the JSON output
echo "{\"text\": \"$text\", \"tooltip\": \"\", \"class\": \"$class\"}"
