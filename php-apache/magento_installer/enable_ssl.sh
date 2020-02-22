#!/bin/bash

if [ ! -f $PWD/env ]; then
    cp $PWD/env.sample $PWD/env
fi

chown $SUDO_USER:$SUDO_USER env


source $PWD/env

install_ssl(){

    echo "------------------------------------------------------------------"
	echo "    Creating SSL Virtualhost and enable permanent redirect        "
	echo "------------------------------------------------------------------"

    if [ -z "$SSL_CERTIFICATE_FILE"  ] || [ ! -f "$SSL_CERTIFICATE_FILE" ]
    then
            echo "SSL Certificate file not set or non existent"
            exit
    fi

    if [ -z "$SSL_CERTIFICATE_KEY_FILE" ] || [ ! -f "$SSL_CERTIFICATE_KEY_FILE" ]
    then
            echo "SSL Certificate file not set or non existent"
            exit
    fi

    if [ -z "$SSL_CERTIFICATE_CHAIN_FILE" ] || [ ! -f "$SSL_CERTIFICATE_CHAIN_FILE" ]
    then
            echo "SSL Certificate Chain File not set or non existent"
            exit
    fi

    a2enmod ssl

    cp magento_ssl.conf /etc/apache2/sites-available/

        sed -i "s/#RewriteEngine.*/RewriteEngine On/g" "/etc/apache2/sites-available/magento.conf"
        sed -i "s/#RewriteRule/RewriteRule/g" "/etc/apache2/sites-available/magento.conf"

    if [ ! -z "$MAGENTO_URL" ];
	then
	    sed -i "s|example.com|$MAGENTO_URL|g"  "/etc/apache2/sites-available/magento_ssl.conf"
        sed -i "s|example.com|$MAGENTO_URL|g"  "/etc/apache2/sites-available/magento.conf"
    else
        echo "Servername not filled in env"
	fi

	if [ ! -z "$MAGENTO_ADMIN_EMAIL" ]; 
	then
    	sed -i "s|ServerAdmin.*|ServerAdmin $MAGENTO_ADMIN_EMAIL|g"  "/etc/apache2/sites-available/magento_ssl.conf"
      	sed -i "s|ServerAdmin.*|ServerAdmin $MAGENTO_ADMIN_EMAIL|g"  "/etc/apache2/sites-available/magento.conf"
	fi


    sed -i "s|SSLCertificateFile.*|SSLCertificateFile $SSL_CERTIFICATE_FILE|g"  "/etc/apache2/sites-available/magento_ssl.conf"

	sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile $SSL_CERTIFICATE_KEY_FILE|g"  "/etc/apache2/sites-available/magento_ssl.conf"

	sed -i "s|SSLCertificateChainFile.*|SSLCertificateChainFile $SSL_CERTIFICATE_CHAIN_FILE|g"  "/etc/apache2/sites-available/magento_ssl.conf"

	a2ensite magento_ssl.conf

	service apache2 restart

}

install_ssl