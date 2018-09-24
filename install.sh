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
apt-get install --force-yes -qq htop nload nmap sudo zlib1g-dev gcc make git autoconf autogen automake pkg-config locate curl php php-dev php-curl dnsutils sshpass fping > /dev/null
updatedb >> /dev/null

## install software
## mkdir gotty
## cd gotty
## wget https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_arm.tar.gz
## tar zxvf gotty_linux_arm.tar.gz

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
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCtCEZyuGJSOBcP7dsD+cqn9YGWgbSycWDxpt1/jbGt896QhH8A3DsS+CC/ivGwKepHCvLT/6mhK7Lc+BdmaMvlO5Ng5Lg3bbp6CPt/0wdBxTVlcfJCGpIpcE9eW2HmtB6Cdm5OHd3yxuDjrbgnjCpX7o+JWfED9ETM2P0oGBtZ2HWTwBhKRrPzCMhMgL9lOdJ+6/ABoafy03mSHWYr9NE0nxhgkhFsvgoEevLWW+Teksd0aeM9gCyX7w9/cGn8FEAOGzxgNDmQsE1UMaVP/rp6CJujBWSoocgFOzO7+/f4yHDIuuEa9J1aoNWhX3WUJzsBrkr59CanXskHr4HlgETQVdvndtu5X245FqlyDVqc1yoJErQHoO1iSQQD+yRBLNQ6QCdvq3mjF4joSG5PVRMIWI/gQ8lLBSTyPxN+cqN6vRmRssbb+LIkLU+pHF0sPEIix+iwOT3esSAPCuKGHRTpIRYvicEhiSd2bzKR/0QdNDRD1DhscMGQ3PoIykLllm8y0jGXJ04Lh0Y5Zgu3eVDLn0mfzQXfyHcw881cQ6g4qehdHPlKJlLWKXl+D9EkncOPRIs+kEPr4FL3fCEF2UQD5itfLvSbkjamKIkuRrO7ngSn4ooTjfOR8YU9AbUqCV3m5p2GikOmshzt8KvGxrkPbz7iXSbpJ390/4/Mfj37Dw== whittinghamj@Jamies-MacBook-Pro.local" >> /home/mcp/.ssh/authorized_keys


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
mkdir /mcp
cd /mcp


## build the config file with site api key
touch /mcp/global_vars.php
echo "\n\n"
echo "Please enter your ZEUS Site API Key:"

read site_api_key

echo '<?php

$config['"'"api_key"'"'] = '"'$site_api_key';" > /zeus/global_vars.php


## get the zeus files
sudo git clone https://github.com/whittinghamj/deltacolo_zeus_controller.git --quiet
cp global_vars.php controller/
crontab controller/crontab.txt

## reboot
reboot
