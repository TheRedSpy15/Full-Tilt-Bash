#!/bin/sh

if [ $(whoami) != "root" ];
then
    echo "Must be root to run script"
    exit
fi

echo "Checking for apt-fast (faster)"
if [ $(dpkg-query -W -f='${Status}' aptfast 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "apt-fast installed" ## apt-fast

    apt-fast update
    apt-fast upgrade
    apt-fast dist-upgrade
    apt-fast autoremove
    apt-fast autoclean
    apt-fast check
    update-grub
else
    echo "apt-fast not installed" ## apt-get
    echo "Using default process"

    apt-get update
    apt-get upgrade
    apt-get dist-upgrade
    apt-get autoremove
    apt-get autoclean
    apt-get check
    update-grub
fi