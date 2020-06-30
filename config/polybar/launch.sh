#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar -rq music &
    MONITOR=$m polybar -rq tray &
    MONITOR=$m polybar -rq i3 &
  done
else
    polybar -rq music &
    polybar -rq tray &
    polybar -rq i3 &
fi

# polybar -rq dummy &

echo "Polybar launched..."
