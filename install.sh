#!/bin/bash

sudo mkdir /tmp/setup-li-ni/
sudo cp -r * /tmp/setup-li-ni/
cd $HOME
sudo apt install apt-transport-https curl
curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh && bash $HOME/nodesource_setup.sh
sudo rm $HOME/nodesource_setup.sh
sudo apt-get install nodejs git neovim openjdk-14-jdk gnome-tweaks gnome-shell-extensions wget -y && sudo apt-get update
git config --global credential.helper cache
sudo sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
sudo mkdir -p $HOME/.config/nvim/
sudo rm $HOME/.config/nvim/init.vim
sudo mv /tmp/setup-li-ni/.config/nvim/init.vim $HOME/.config/nvim/
wget https://mirror.netcologne.de/apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
tar xzvf apache-maven-3.6.3-bin.tar.gz
sudo mv apache-maven-3.6.3 /opt/
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -

sudo rm $HOME/apache-maven-3.6.3-bin.tar.gz

echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update && sudo apt install brave-browser -y

sudo rm $HOME/.bashrc

sudo mv /tmp/setup-li-ni/.bashrc $HOME/

wget http://repository.spotify.com/pool/non-free/s/spotify-client/spotify-client_1.1.26.501.gbe11e53b-15_amd64.deb
sudo rm $HOM/spotify-client_1.1.26.501.gbe11e53b-15_amd64.deb

wget https://discord.com/api/download?platform=linux&format=deb && sudo apt install $HOME/discord-0.0.10.deb
sudo rm $HOME/discord-0.0.10.deb

sudo rm -rf /opt/setup-li-ni

echo done!



