#!/bin/bash

## MCP Controller - Install Script
echo "MCP Controller - Install Script"


## set base folder
cd /root


## update apt-get repos
echo "Updating Repos"
apt-get update > /dev/null


## upgrade all packages
echo "Upgrading Core OS"
apt-get --force-yes -qq upgrade > /dev/null


## install dependencies
echo "Installing Dependencies"
apt-get install --force-yes -qq htop nload nmap sudo zlib1g-dev gcc make git autoconf autogen automake pkg-config locate curl php php-dev php-curl dnsutils sshpass fping shellinabox > /dev/null
updatedb >> /dev/null


## configure shellinabox
sudo sed -i 's/--no-beep/--no-beep --disable-ssl/g' /etc/default/shellinabox
sudo invoke-rc.d shellinabox restart


## install software


cd /root

## download custom scripts
echo "Downloading custom scripts"
wget -q http://scripts.miningcontrolpanel.com/scripts/speedtest.sh
rm -rf /root/.bashrc
wget -q http://scripts.miningcontrolpanel.com/scripts/.bashrc
wget -q http://scripts.miningcontrolpanel.com/scripts/myip.sh
rm -rf /etc/skel/.bashrc
cp /root/.bashrc /etc/skel
chmod 777 /etc/skel/.bashrc
cp /root/myip.sh /etc/skel
chmod 777 /etc/skel/myip.sh


## setup whittinghamj account
echo "Adding admin linux user account"
useradd -m -p eioruvb9eu839ub3rv mcp
echo "mcp:"'mcp' | chpasswd > /dev/null
usermod --shell /bin/bash mcp
mkdir /home/mcp/.ssh
echo "Host *" > /home/mcp/.ssh/config
echo " StrictHostKeyChecking no" >> /home/mcp/.ssh/config
chmod 400 /home/mcp/.ssh/config
usermod -aG sudo mcp
echo "mcp    ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers


## lock pi account
## echo "Securing default Raspberry Pi user account"
## echo "pi:"'jneujefiuberjuvbefrivjubeivubervihbeivubev38484h' | chpasswd > /dev/null
## usermod --lock --shell /bin/nologin pi


## update root account
mkdir /root/.ssh
echo "Host *" > /root/.ssh/config
echo " StrictHostKeyChecking no" >> /root/.ssh/config

## change SSH port to 33077 and only listen to IPv4
echo "Updating SSHd details"
sed -i 's/#Port 22/Port 33077/' /etc/ssh/sshd_config
sed -i 's/#AddressFamily any/AddressFamily inet/' /etc/ssh/sshd_config
/etc/init.d/ssh restart > /dev/null


## set controller hostname
echo "Setting hostname"
echo 'controller' > /etc/hostname
echo "127.0.0.1       controller" >> /etc/hosts


## make zeus folders
## echo "Installing MCP"
mkdir /zeus
cd /zeus


## build the config file with site api key
touch /zeus/global_vars.php
echo "\n\n"
echo "Please enter your MCP Site API Key:"

read site_api_key

echo '<?php

$config['"'"api_key"'"'] = '"'$site_api_key';" > /zeus/global_vars.php


## get the zeus files
mkdir controller
cd controller
sudo git clone https://github.com/whittinghamj/deltacolo_zeus_controller.git --quiet
cp global_vars.php controller/
crontab /zeus/controller/crontab.txt

## reboot
reboot
