#!/bin/bash
# 1. Network
net=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2 || echo 'Offline')
if [ ${#net} -gt 15 ]; then net="${net:0:12}..."; fi
# 2. Battery
bat_cap=$(cat /sys/class/power_supply/BAT0/capacity)
bat_stat=$(cat /sys/class/power_supply/BAT0/status)
if [ "$bat_stat" = "Charging" ]; then icon="󰂄"; else icon="󰁹"; fi
# 3. Load
cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}' | cut -d. -f1)
# Output 3 lines for the vertical stack
echo "󰖩  $net"
echo "$icon  $bat_cap% ($bat_stat)"
echo "󰍛  Load: $cpu%"
