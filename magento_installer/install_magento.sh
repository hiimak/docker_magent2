#!/bin/bash

if [ ! -f $PWD/env ]; then
    cp $PWD/env.sample $PWD/env
fi

chown $SUDO_USER:$SUDO_USER env

source $PWD/env

download_magento(){

    echo "------------------------------------------------------------------"
	echo "     Download Magento2 via Composer        "
	echo "------------------------------------------------------------------"

	rm -r /var/www/magento2

    mkdir /var/www/magento2/

	if [ -d "$HOME/.composer" ];
	then
    	cp auth.json $HOME/.composer/
	else
		mkdir $HOME/.composer/
		cp auth.json $HOME/.composer/
	fi		
    composer create-project --repository=https://repo.magento.com/ magento/project-community-edition "/var/www/magento2"

    rm $HOME/.composer/auth.json

}


install_magento(){

	mysql -u root -e "DROP DATABASE $MYSQL_MAGENTO_DATABASE;"
	mysql -u root -e "CREATE USER IF NOT EXISTS '${MYSQL_MAGENTO_USER}'@'localhost' identified by '${MYSQL_MAGENTO_PASSWORD}';"
	mysql -u root -e "CREATE DATABASE ${MYSQL_MAGENTO_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
	mysql -u root -e "GRANT all privileges on ${MYSQL_MAGENTO_DATABASE}.* to '${MYSQL_MAGENTO_USER}'@'localhost'; Flush privileges;"

	
	if [ $MAGENTO_USE_SECURE -eq 1 ]; then
		/var/www/magento2/bin/magento setup:install --base-url-secure="https://${MAGENTO_URL}" --backend-frontname=$MAGENTO_BACKEND_FRONTNAME --language=$MAGENTO_LANGUAGE --timezone=$MAGENTO_TIMEZONE --currency=$MAGENTO_DEFAULT_CURRENCY --db-host=$MYSQL_HOST --db-name=$MYSQL_MAGENTO_DATABASE --db-user=$MYSQL_MAGENTO_USER --db-password=$MYSQL_MAGENTO_PASSWORD --use-secure=$MAGENTO_USE_SECURE --use-secure-admin=$MAGENTO_USE_SECURE_ADMIN --admin-firstname=$MAGENTO_ADMIN_FIRSTNAME --admin-lastname=$MAGENTO_ADMIN_LASTNAME --admin-email=$MAGENTO_ADMIN_EMAIL --admin-user=$MAGENTO_ADMIN_USERNAME --admin-password=$MAGENTO_ADMIN_PASSWORD
	else
		/var/www/magento2/bin/magento setup:install --base-url="http://${MAGENTO_URL}" --backend-frontname=$MAGENTO_BACKEND_FRONTNAME --language=$MAGENTO_LANGUAGE --timezone=$MAGENTO_TIMEZONE --currency=$MAGENTO_DEFAULT_CURRENCY --db-host=$MYSQL_HOST --db-name=$MYSQL_MAGENTO_DATABASE --db-user=$MYSQL_MAGENTO_USER --db-password=$MYSQL_MAGENTO_PASSWORD --use-secure=$MAGENTO_USE_SECURE --base-url-secure=$MAGENTO_BASE_URL_SECURE --use-secure-admin=$MAGENTO_USE_SECURE_ADMIN --admin-firstname=$MAGENTO_ADMIN_FIRSTNAME --admin-lastname=$MAGENTO_ADMIN_LASTNAME --admin-email=$MAGENTO_ADMIN_EMAIL --admin-user=$MAGENTO_ADMIN_USERNAME --admin-password=$MAGENTO_ADMIN_PASSWORD
	fi

	chown -R www-data:www-data /var/www/

}


install_apache_virtual_host(){

    echo "------------------------------------------------------------------"
	echo "   Creating Virtualhost for magento      "
    echo "   Magentoroot /var/www/magento2"
	echo "------------------------------------------------------------------"

	a2dissite 000-default.conf

	cp magento.conf /etc/apache2/sites-available/

	if [! -z "$MAGENTO_URL" ]
	then
	    sed -i "s/example.com/$MAGENTO_URL/g"  "/etc/apache2/sites-available/magento.conf"
	fi

	if [! -z "$MAGENTO_ADMIN_EMAIL" ]
	then
		sed -i "s/ServerAdmin.*/ServerAdmin $MAGENTO_ADMIN_EMAIL/g"  "/etc/apache2/sites-available/magento.conf"
	fi

	a2ensite magento.conf

	apache2ctl configtest
	service apache2 restart

	echo "------------------------------------------------------------------"
	echo "    You can install Magento over the Webbrowser now "
	echo " 	  Visit http://localhost        "
	echo "------------------------------------------------------------------"


}

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



set_mode(){

	chown www-data:www-data -R /var/www/magento2

    if [ $1 == "-dev" ]; then
        /var/www/magento2/bin/magento deploy:mode:set developer
        chmod 777 -R /var/www/magento2
    fi

    if [ $1 == "-prod" ]; then 
        /var/www/magento2/bin/magento deploy:mode:set productio
        find /var/www/magento2/app/code /var/www/magento2/var/view_preprocessed /var/www/magento2/vendor /var/www/magento2/pub/static /var/www/magento2/app/etc /var/www/magento2/generated/code /var/www/magento2/generated/metadata \( -type f -or -type d \) -exec chmod u-w {} + && chmod o-rwx /var/www/magento2/app/etc/env.php && chmod u+x /var/www/magento2/bin/magento
    fi
}


download_magento
install_magento
set_mode


install_apache_virtual_host
install_ssl