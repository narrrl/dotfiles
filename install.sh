#!/bin/sh

mkdir ~/.config
cp -r ./config/* ~/.config/
cp ./zshrc ~/.zshrc
cp ./zshenv ~/.zshenv
cp ./zprofile ~/.zprofile
sudo mkdir /usr/share/sddm/themes/ -p
sudo 7z x ./sddm/sddm-theme.zip  /usr/share/sddm/themes/
sudo mkdir /etc/sddm.conf.d -p
sudo cp ./sddm/default.conf /etc/sddm.conf.d/
sudo cp -r ./LS_COLORS /usr/share/
