#!/bin/bash
status=$(playerctl status 2>/dev/null)
if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
  title=$(playerctl metadata title | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
  artist=$(playerctl metadata artist | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
  if [ ${#title} -gt 25 ]; then title="${title:0:22}..."; fi
  if [ ${#artist} -gt 25 ]; then artist="${artist:0:22}..."; fi
  echo "<span weight='bold' foreground='#cba6f7'>$title</span>"
  echo "<span foreground='#bac2de' size='small'>$artist</span>"
else
  echo "<span weight='bold' foreground='#cdd6f4'>No Media</span>"
  echo "<span size='small' foreground='#a6adc8'>Idling</span>"
fi
