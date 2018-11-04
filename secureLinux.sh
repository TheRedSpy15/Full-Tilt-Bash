#!/bin/sh

## TODO: finish blacklisted domains
## TODO: remove untrustworthy ca certificates
## TODO: change ssh port to 2222
## TODO: disable guest login

if [ $(whoami) != "root" ]; 
then
    echo "Must be root to run script"
    exit
fi

## Firewall - need if statement
echo "Enabling firewall"
ufw enable

## Clamav
echo "Checking for clamav"
if [ $(dpkg-query -W -f='${Status}' clamav 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "Installing anti-virus"
    apt-get install clamav
else
    echo "Clamav already installed"
fi

## rkhunter
echo "Checking for rkhunter"
if [ $(dpkg-query -W -f='${Status}' rkhunter 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "Installing anti-rootkit"
    sudo apt-get install rkhunter
else
    echo "rkhunter already installed"
fi

## Root login
echo "Checking if root login allowed"
File="/etc/ssh/sshd_config"
if ! grep -q 'DenyUsers root' "$File"; 
then
    echo "Disabling root login sshd"
    echo "DenyUsers root" >> /etc/ssh/sshd_config
else
    echo "Root login already disabled"
fi

## BUG: sed: can't read : No such file or directory
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' "$FIle" ## is a check within itself

## SSH port
## need check for this one as port number could be changed to something other than 22 or 2222
## BUG: sed: can't read : No such file or directory
echo "Checking SSH port number"
if grep -q 'Port 22' "$File"; 
then
    echo "Changing SSH port to 2222"
    sed -i 's/Port 22/Port 2222/g' "$FIle" 
else
    echo "SSH port already changed from default"
fi

## Insecure protocols - need if statement
echo "Removing insecure protocols"
yum erase xinetd ypserv tftp-server telnet-server rsh-server

## Maximum password age - no need for if statement
echo "Enforcing maximum password age (100 days)"
chage -M 100 root

## Insecure IO - thunderbolt
echo "Checking for insecure IO ports"
File="/etc/modprobe.d/thunderbolt.conf"
if [ -e "$File" ]; 
then
    if ! grep -q 'blacklist thunderbolt' "$File"; 
    then
        echo "Disabling thunderbolt connections"
        echo "blacklist thunderbolt" >> /etc/modprobe.d/thunderbolt.conf
    fi
fi

## Insecure IO - firewire
File="/etc/modprobe.d/firewire.conf"
if [ -e "$File" ]; 
then
    if ! grep -q 'blacklist firewire-core' "$File"; 
    then
        echo "Disabling firewire"
        echo "blacklist firewire-core" >> /etc/modprobe.d/firewire.conf
    fi
fi

## fail2ban
echo "Checking for fail2ban"
if [ $(dpkg-query -W -f='${Status}' fail2ban 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "Installing fail2ban"
    sudo apt-get install fail2ban
else
    echo "fail2ban already installed"
fi

## Malicious domains
## TODO: add domains from this list: https://www.malwaredomainlist.com/hostslist/hosts.txt
## but with 0.0.0.0 instead of 127.0.0.1
echo "Black-listing malicious domains"
File="/etc/hosts"
if ! grep -q 'totalvirus.com' "$File"; 
then
    echo 'Black-listing "totalvirus.com"'
    echo "0.0.0.0 totalvirus.com" >> /etc/hosts
fi