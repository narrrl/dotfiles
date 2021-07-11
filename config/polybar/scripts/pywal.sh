#!/usr/bin/env bash

# Color files
PFILE="$HOME/.config/polybar/colors.ini"
RFILE="$HOME/.config/polybar/scripts/rofi/colors.rasi"

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
	sed -i -e "s/shade1 = #.*/shade1 = $SH1/g" $PFILE
	sed -i -e "s/shade2 = #.*/shade2 = $SH2/g" $PFILE
	sed -i -e "s/shade3 = #.*/shade3 = $SH3/g" $PFILE
	sed -i -e "s/shade4 = #.*/shade4 = $SH4/g" $PFILE
	sed -i -e "s/shade5 = #.*/shade5 = $SH5/g" $PFILE
	sed -i -e "s/shade6 = #.*/shade6 = $SH6/g" $PFILE
	sed -i -e "s/shade7 = #.*/shade7 = $SH7/g" $PFILE
	sed -i -e "s/shade8 = #.*/shade8 = $SH8/g" $PFILE

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
	TBG=`printf "%s\n" "#dd${background:1}"`
	BG=`printf "%s\n" "$background"`
	FG=`printf "%s\n" "$foreground"`
	FGA=`printf "%s\n" "$color8"`
	SH1=`printf "%s\n" "$color1"`
	SH2=`printf "%s\n" "$color2"`
	SH3=`printf "%s\n" "$color1"`
	SH4=`printf "%s\n" "$color2"`
	SH5=`printf "%s\n" "$color1"`
	SH6=`printf "%s\n" "$color2"`
	SH7=`printf "%s\n" "$color1"`
	SH8=`printf "%s\n" "$color7"`

	change_color
else
	echo "[!] 'pywal' is not installed."
fi