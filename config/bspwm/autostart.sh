
## compositors (start only one)

# picom --config $HOME/.config/picom.conf --experimental-backends &
xcompmgr -c &

# bloat (yay)
openrgb -m static -c fff5ee &
gnome-keyring-daemon --start &
fcitx5 -d &
$HOME/.config/polybar/launch.sh &
source ~/.fehbg &

## fixes

## mic mono map
$HOME/.config/polybar/scripts/map_mono_mic.sh &

## fix intellij repainting shit
wmname LG3D


## autostart
discord --no-sandbox --start-minimized &
