#!/bin/sh

echo "Enabling firewall"
ufw enable

echo "Installing anti-virus"
apt-get install clamav

echo "Installing anti-rootkit"
sudo apt-get install rkhunter

File="/etc/ssh/sshd_config"
if grep -q STRING_YOU_ARE_CHECKING_FOR "$File"; 
then
echo "Disabling root login ssh"
echo "DenyUsers root" >> /etc/ssh/sshd_config
else
echo "Root login for ssh already disabled"
fi