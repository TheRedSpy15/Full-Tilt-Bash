#!/bin/sh

## TODO: Check for already installed

if [ $(whoami) != "root" ]; 
then
    echo "Must be root to run script"
    exit
fi

## Nmap
echo "installing Nmap"
echo "adding repository"
add-apt-repository ppa:pi-rho/security
echo "updating"
apt-get update
echo "installing"
apt-get install nmap

## Wireshark
echo "installing Wireshark"
echo "adding repository"
add-apt-repository ppa:wireshark-dev/stable
echo "updating"
apt-get update
echo "installing"
apt-get install wireshark

## echo "installing Firejail"

## echo "installing Firetools"

## echo "installing OpenJDK"

## echo "installing Angry-Ip-Scanner"

## Metasploit
echo "installing Metasploit"
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
  chmod 755 msfinstall && \
  ./msfinstall

## Reaver
echo "installing Reaver"
apt-get install reaver

## Aircrack-ng
apt-get install aircrack-ng

## echo "installing Visual Studio Code"

## Fsociety
echo "installing fsociety"
bash <(wget -qO- https://git.io/vAtmB)