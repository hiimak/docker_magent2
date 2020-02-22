#!/bin/bash

install_software(){

	echo "------------------------------------------------------------------"
	echo "     Apache2        "
	echo "------------------------------------------------------------------"
	
	apt update
	apt install -y apache2
    
    a2enmod rewrite

	cp /opt/docker/etc/apache2/sites-available/* /etc/apache2/sites-available/

	systemctl enable apache2
	
	apt-get install git -y

}



install_apache_virtual_host(){

    echo "------------------------------------------------------------------"
	echo "   Creating Virtualhost for magento      "
    echo "   Magentoroot /var/www/magento2"
	echo "------------------------------------------------------------------"

	a2dissite 000-default.conf

	if [! -z "$MAGENTO_URL" ]
	then
	    sed -i "s/example.com/$MAGENTO_URL/g"  "/etc/apache2/sites-available/magento.conf"
	fi

	if [! -z "$MAGENTO_ADMIN_EMAIL" ]
	then
		sed -i "s/ServerAdmin.*/ServerAdmin $MAGENTO_ADMIN_EMAIL/g"  "/etc/apache2/sites-available/magento.conf"
	fi

	a2ensite default.conf

	apache2ctl configtest
	service apache2 restart

	echo "------------------------------------------------------------------"
	echo "    You can install Magento over the Webbrowser now "
	echo " 	  Visit http://localhost        "
	echo "------------------------------------------------------------------"


}

install_software
install_apache_virtual_host