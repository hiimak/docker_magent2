#!/bin/bash

apt purge mysql-* -y 
apt pruge phpmyadmin -y
apt purge apache2 -y 
apt purge php7.2* -y

apt autoclean -y
apt autoremove -y

apt-get remove dbconfig-mysql
apt-get dist-upgrade -y

ufw reset
ufw disable

rm -r /var/www/magento2/
rm -r /etc/apache2/
rm -r /etc/php/
rm -r /etc/mysql/

