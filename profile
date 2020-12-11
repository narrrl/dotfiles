
export PATH=~/scripts:$PATH
xwallpaper --zoom ~/.config/wall.png
fcitx

export QT_QPA_PLATFORMTHEME="qt5ct"
export EDITOR=/usr/bin/nano
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
# fix "xdg-open fork-bomb" export your preferred browser from here
export BROWSER=/usr/bin/brave
export PATH=/home/nr99/Programme:$PATH
export TERM=alacritty

xrandr --output DP-0 --auto --primary --output HDMI-0 --auto --left-of DP-0
setxkbmap -layout usde
