#!/bin/sh

## TODO: finish blacklisted domains
## TODO: remove untrustworthy ca certificates
## TODO: disable guest login
## TODO: disable ssh v1
## TODO: add openssh support
## TODO: review steps that modify system files
## TODO: limit to only one instance

## Root/sudo check
if [ $(whoami) != "root" ]; 
then
    echo "Must be root to run script"
    exit
fi

## Full system update
apt-get update
apt-get upgrade
apt-get dist-upgrade
apt-get autoremove
apt-get autoclean
apt-get check

## Firewall - need if statement
echo "Enabling firewall"
ufw enable

## Limit SSH connections
echo "Limiting ssh connections"
ufw limit ssh
ufw limit openssh

## Automatic updates
echo "Enforcing automatic updates"
sed -i 's/Update-Package-Lists "0"/Update-Package-Lists "1"/g' /etc/apt/apt.conf.d/20auto-upgrades

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

sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config ## is a check within itself

## SSH port - review as default sshd_config might need to uncomment port number
## need check for this one as port number could be already changed to something other than 22 or 3333
echo "Checking SSH port number"
if grep -q 'Port 22' "$File"; 
then
    echo "Changing SSH port to 3333"
    sed -i 's/Port 22/Port 3333/g' /etc/ssh/sshd_config 
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