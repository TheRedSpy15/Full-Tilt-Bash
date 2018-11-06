#!/bin/sh

## TODO: Check for already installed
## TODO: Install Webmin
## TODO: Install Joomla
## TODO: Install Wine
## TODO: Install Clamav
## TODO: Install Zabbix
## TODO: Install phpipam

## Root/sudo check
if [ $(whoami) != "root" ]; 
then
    echo "Must be root to run script"
    exit
fi

## Clamav
echo "Checking for clamav"
if [ $(dpkg-query -W -f='${Status}' clamav 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "Installing anti-virus"
    apt-get install clamav
else
    echo "Clamav already installed"
fi

## Apache
echo "Checking for Apache"
if [ $(dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "Installing Apache"
    apt install apache2
else
    echo "Apache already installed"
fi

## My-SQL
echo "Checking for My-SQL"
if [ $(dpkg-query -W -f='${Status}' mysql-server 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "Installing My-SQL"
    apt-get install mysql-server
else
    echo "My-SQL already installed"
fi


## PHP
echo "Checking for PHP"
if [ $(dpkg-query -W -f='${Status}' php 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
    echo "Installing PHP"
    apt install php-pear php-fpm php-dev php-zip php-curl php-xmlrpc php-gd php-mysql php-mbstring php-xml libapache2-mod-php
else
    echo "PHP already installed"
fi

## Finalize
echo "restarting Apache"
service apache2 restart
