#!/usr/bin/env bash

# Color files
PFILE="$HOME/.config/polybar/colors.ini"
RFILE="$HOME/.config/polybar/scripts/rofi/colors.rasi"
DUNSTFILE="$HOME/.config/dunst/dunstrc"

# Get colors
pywal_get() {
	if [ -z "$2" ]; then
		printf "No backend\n"
		wal -i "$1" -q -t
	else
		printf "With backend $2\n"
		wal --backend "$2" -i "$1" -q -t
	fi

}

# Change colors
change_color() {
	# polybar
	sed -i -e "s/background = #.*/background = $TBG/g" $PFILE
	sed -i -e "s/foreground = #.*/foreground = $FG/g" $PFILE
	sed -i -e "s/foreground-alt = #.*/foreground-alt = $FGA/g" $PFILE
	sed -i -e "s/shade1 = #.*/shade1 = $TSH1/g" $PFILE
	sed -i -e "s/shade2 = #.*/shade2 = $TSH2/g" $PFILE
	sed -i -e "s/shade3 = #.*/shade3 = $TSH3/g" $PFILE
	sed -i -e "s/shade4 = #.*/shade4 = $TSH4/g" $PFILE
	sed -i -e "s/shade5 = #.*/shade5 = $TSH5/g" $PFILE
	sed -i -e "s/shade6 = #.*/shade6 = $TSH6/g" $PFILE
	sed -i -e "s/shade7 = #.*/shade7 = $TSH7/g" $PFILE
	sed -i -e "s/shade8 = #.*/shade8 = $TSH8/g" $PFILE
	sed -i -e "s/backgound = \"#.*\"/background = \"$BG\"/g" $DUNSTFILE
	sed -i -e "s/frame_color = \"#.*\"/frame_color = \"$BG\"/g" $DUNSTFILE
	sed -i -e "s/foreground = \"#.*\"/foreground = \"$FG\"/g" $DUNSTFILE
	killall dunst
	notify-send "Changed colors!"

	# rofi
	cat > $RFILE <<- EOF
	/* colors */

	* {
	  al:    #00000000;
	  bg:    ${BG}FF;
	  bg1:   ${SH2}FF;
	  bg2:   ${SH3}FF;
	  bg3:   ${SH4}FF;
	  bg4:   ${SH5}FF;
	  fg:    ${FG}FF;
	}
	EOF

	polybar-msg cmd restart
}

# Main
if [[ -f "/usr/bin/wal" ]]; then
	if [[ "$1" && "$2" ]]; then
		pywal_get "$1" "$2"
	elif [[ "$1" ]]; then
		pywal_get "$1"
	else
		echo -e "[!] Please enter the path to wallpaper. \n"
		echo "Usage : ./pywal.sh path/to/image"
	fi
	# Source the pywal color file
	. "$HOME/.cache/wal/colors.sh"

	# transparent background
	TBG=`printf "%s\n" "#99${background:1}"`
	BG=`printf "%s\n" "$background"`
	FG=`printf "%s\n" "$foreground"`
	TFG=`printf "%s\n" "#BF${foreground:1}"`
	FGA=`printf "%s\n" "$color8"`
	TFGA=`printf "%s\n" "#BF${color8:1}"`
	SH1=`printf "%s\n" "$color1"`
	SH2=`printf "%s\n" "$color2"`
	SH3=`printf "%s\n" "$color1"`
	SH4=`printf "%s\n" "$color2"`
	SH5=`printf "%s\n" "$color1"`
	SH6=`printf "%s\n" "$color2"`
	SH7=`printf "%s\n" "$color1"`
	SH8=`printf "%s\n" "$color7"`
	TSH1=`printf "%s\n" "#BF${color1:1}"`
	TSH2=`printf "%s\n" "#BF${color2:1}"`
	TSH3=`printf "%s\n" "#BF${color1:1}"`
	TSH4=`printf "%s\n" "#BF${color2:1}"`
	TSH5=`printf "%s\n" "#BF${color1:1}"`
	TSH6=`printf "%s\n" "#BF${color2:1}"`
	TSH7=`printf "%s\n" "#BF${color1:1}"`
	TSH8=`printf "%s\n" "#BF${color7:1}"`

	change_color
else
	echo "[!] 'pywal' is not installed."
fi
