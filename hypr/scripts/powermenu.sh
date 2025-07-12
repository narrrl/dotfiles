#!/bin/bash
options="Shutdown\nReboot\nLock\nLogout"
selected=$(echo -e $options | fuzzel --dmenu --prompt='Power:')

case $selected in
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Lock")
        hyprlock
        ;;
    "Logout")
        hyprctl dispatch exit
        ;;
esac
