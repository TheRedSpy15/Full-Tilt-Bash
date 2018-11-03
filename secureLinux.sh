#!/bin/sh

## TODO: add more checks for already applied security steps

if [[ `id -u` != 0 ]]; 
then
    echo "Must be root to run script"
    exit
fi

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

echo "Removing insecure protocols"
yum erase xinetd ypserv tftp-server telnet-server rsh-server

echo "Enforcing maximum password age"
chage -M 100 root

echo "Disable insecure IO ports"
echo "blacklist firewire-core" >> /etc/modprobe.d/firewire.conf
echo "blacklist thunderbolt" >> /etc/modprobe.d/thunderbolt.conf

echo "installing fail2ban"
apt-get install fail2ban