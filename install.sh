#!/bin/bash
curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo rm -rf nodesource_setup.sh
sudo apt-get install nodejs -y
sudo apt-get install neovim -y
sudo apt-get install openjdk-14-jdk -y
sudo apt-get install gnome-tweaks -y
sudo apt-get install gnome-shell-extensions -y
sudo apt-get install wget -y
sudo apt-get update
sudo sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
sudo cp -r .config/nvim/* ~/.config/nvim/
wget https://mirror.netcologne.de/apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
tar xzvf apache-maven-3.6.3-bin.tar.gz
sudo rm -rf /opt/apache-maven-3.6.3
sudo mv apache-maven-3.6.3 /opt/
sudo rm -rf apache-master-3.6.3-bin.tar.gz
sudo rm -rf apache-maven-3.6.3

sudo apt install apt-transport-https curl

curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -

echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt update

sudo apt install brave-browser -y

sudo rm ~.bashrc
sudo cp .bashrc ~
