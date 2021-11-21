#!/usr/bin/sh
if (($(ps -aux | grep [p]icom | wc -l) > 0))
then
  polybar-msg hook blur 1 && pkill -9 picom
else
  polybar-msg hook blur 2 && picom -b --config=$HOME/.config/picom.conf &
fi
