#!/bin/sh

# TODO: Check for already installed

apt-get update
apt-get upgrade
apt-get dist-upgrade
apt-get autoremove
apt-get autoclean
apt-get check
