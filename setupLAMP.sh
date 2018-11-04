#!/bin/sh

## TODO: Check for already installed
## TODO: Install Webmin
## TODO: Install Joomla
## TODO: Install Wine
## TODO: Install Clamav
## TODO: Install Zabbix
## TODO: Install phpipam

echo "installing Apache"
apt install apache2

echo "installing My-SQL"
apt install mysql-server

echo "installing PHP"
apt install php-pear php-fpm php-dev php-zip php-curl php-xmlrpc php-gd php-mysql php-mbstring php-xml libapache2-mod-php

echo "restarting server"
service apache2 restart
