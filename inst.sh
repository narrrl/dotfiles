#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

sudo pacman -S playerctl brave py3status picom neovim

cd /tmp && git clone https://aur.archlinux.org/yay.git

cd yay && makepkg -si

yay -S gtk-theme-arc-gruvbox-git ttf-font-awesome-4 ttf-twemoji arc-icon-theme

cp -r $DIR/config/* $HOME/.config/
cp -r $DIR/scripts $HOME/.scripts
cp -r $DIR/dmenurc $HOME/.dmenurc
cp $DIR/gtkrc-2.0 $HOME/.gtkrc-2.0
cp $DIR/profile $HOME/.profile
cp $DIR/Xresources $HOME/.Xresources
sudo cp $DIR/conky_bar /usr/share/conky/
sudo cp $DIR/start_conky_bar /usr/bin/

printf "done!\n"


