#!/bin/sh

if [[ `id -u` != 0 ]]; 
then
    echo "Must be root to run script"
    exit
fi

echo "Enabling firewall"
ufw enable

if [ $(dpkg-query -W -f='${Status}' clamav 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "Installing anti-virus"
    apt-get install clamav
fi

if [ $(dpkg-query -W -f='${Status}' rkhunter 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "Installing anti-rootkit"
    sudo apt-get install rkhunter
fi

File="/etc/ssh/sshd_config"
if grep -q 'DenyUsers root' "$File"; 
then
    echo "Disabling root login sshd"
    echo "DenyUsers root" >> /etc/ssh/sshd_config
fi

sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' "$FIle"

echo "Removing insecure protocols"
yum erase xinetd ypserv tftp-server telnet-server rsh-server

echo "Enforcing maximum password age"
chage -M 100 root

File="/etc/modprobe.d/firewire.conf"
if grep -q STRING_YOU_ARE_CHECKING_FOR "$File"; 
then
    echo "Disabling firewire"
    echo "blacklist firewire-core" >> /etc/modprobe.d/firewire.conf
fi

File="/etc/modprobe.d/thunderbolt.conf"
if grep -q STRING_YOU_ARE_CHECKING_FOR "$File"; 
then
    echo "Disabling thunderbolt connections"
    echo "blacklist thunderbolt" >> /etc/modprobe.d/thunderbolt.conf
fi

if [ $(dpkg-query -W -f='${Status}' fail2ban 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "Installing fail2ban"
    sudo apt-get install fail2ban
fi