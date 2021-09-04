#!/bin/sh
if [ "$(pactl list | grep -c "record_mono")" -eq "0" ] 2> /dev/null && [ "$(pactl list | grep -c "alsa_input.usb-BEHRINGER_UMC204HD_192k-00.analog-stereo")" != "0" ]; then
  # remap mic to mono
  pactl load-module module-remap-source source_name=record_mono master=alsa_input.usb-BEHRINGER_UMC204HD_192k-00.analog-stereo channels=2 channel_map=mono,mono > /dev/null
  # set remapped mic default
  pactl set-default-source record_mono
fi
