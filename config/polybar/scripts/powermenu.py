#!/bin/env python3

import os
import subprocess

action = subprocess.getoutput("echo -e '  Poweroff\n  Reboot\n 﫼 Logout\n  Lock\n  Suspend' | rofi -theme ~/.config/polybar/scripts/rofi/powermenu.rasi -dmenu")

actions = {
    "  Poweroff": ["power off", "systemctl poweroff"],
    "  Reboot": ["reboot","systemctl reboot"],
    " 﫼Logout": ["logout","i3-msg exit"],
    "  Lock": ["lock the computer","~/.config/polybar/scripts/lock.sh"],
    "  Suspend": ["sleep the computer","systemctl suspend"]
}

if action in actions.keys():
    confirm="Confirm"
    if action not in ["  Suspend", "  Lock"]:
        confirm = subprocess.getoutput("echo -e 'Confirm\nCancel' | rofi -theme ~/.config/polybar/scripts/rofi/confirm.rasi -p {0} -dmenu".format("'Are you sure you want to " + actions[action][0] + "?'"));
    if confirm=="Confirm":
        os.system(actions[action][1])
