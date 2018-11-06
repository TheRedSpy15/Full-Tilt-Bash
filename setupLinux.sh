#!/bin/sh

if [ $(whoami) != "root" ]; 
then
    echo "Must be root to run script"
    exit
fi

apt-get update
apt-get upgrade
apt-get dist-upgrade
apt-get autoremove
apt-get autoclean
apt-get check