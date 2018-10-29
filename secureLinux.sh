#!/bin/sh

echo "Enabling firewall"
ufw enable

echo "Installing anti-virus"
apt-get install clamav
