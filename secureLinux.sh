#!/bin/sh

echo "Enabling firewall"
ufw enable

echo "Installing anti-virus"
apt-get install clamav

echo "Installing anti-rootkit"
sudo apt-get install rkhunter