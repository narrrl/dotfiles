#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if pacman -Qi playerctl brave py3status picom neovim > /dev/null ; then
	printf "Required packages installed! skipping...\n"
else
	sudo pacman -S playerctl brave py3status picom neovim
fi

if pacman -Qi yay > /dev/null ; then
	printf "yay is already installed! skipping...\n"
else
	cd /tmp && git clone https://aur.archlinux.org/yay.git
	cd yay && makepkg -si
	rm -rf /tmp/yay
fi

if pacman -Qi gtk-theme-arc-gruvbox-git ttf-font-awesome-4 ttf-twemoji arc-icon-theme > /dev/null ; then
	printf "Yay packages isntalled! skipping...\n"
else
	yay -S gtk-theme-arc-gruvbox-git ttf-font-awesome-4 ttf-twemoji arc-icon-theme
fi

echo -n "Want to apply user settings? (y/n)?"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
	printf "Copying .confg\n"
	cp -r $DIR/config/* $HOME/.config/
	printf "Copying scripts\n"
	cp -r $DIR/scripts $HOME/.scripts
	printf "Copying dmenu config\n"
	cp -r $DIR/dmenurc $HOME/.dmenurc
	printf "Copying gtk-2 config\n"
	cp $DIR/gtkrc-2.0 $HOME/.gtkrc-2.0
	printf "Copying .profile\n"
	cp $DIR/profile $HOME/.profile
	printf "Copying Xresources\n"
	cp $DIR/Xresources $HOME/.Xresources
	printf "Copying conky_bar to /usr/share/conky/. Sudo required!\n"
	sudo cp $DIR/conky_bar /usr/share/conky/
	printf "Copying conky start executable to /usr/bin/. Sudo required!\n"
	sudo cp $DIR/start_conky_bar /usr/bin/
else
	printf "Skipping user settings!\n"
fi

printf "done!\n"


