#!/bin/sh

source $HOME/.cache/wal/colors.sh
default_color="%{u#dd${background:1}}%{+u}"
update_color="%{u#BF${color1:1}}%{+u}"

function updates_count() {
    pac=$(pacman -Qu | wc -l)
    if hash paru 2>/dev/null; then
        echo $(paru -Qu | wc -l)
    elif hash yay 2>/dev/null; then
        echo $(yay -Qu | wc -l)
    else
        echo $pac
    fi
}

ucount=$(updates_count)

if [[ ( "$ucount" == 0 ) ]]; then
    echo "$default_color$ucount"
    polybar-msg hook aur-updates 2
else
    # uncomment for notifications
    # notify-send -i $HOME/.config/polybar/scripts/arch.png "$ucount updates available"
    echo "$update_color$ucount"
    polybar-msg hook aur-updates 1
fi


