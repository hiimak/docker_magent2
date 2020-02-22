#!/bin/bash

if [ ! -f $PWD/env ]; then
    cp $PWD/env.sample $PWD/env
fi

chown $SUDO_USER:$SUDO_USER env

source $PWD/env

apt-get update -y
apt upgrade -y

install_software(){

	echo "------------------------------------------------------------------"
	echo "     Certbot, Apache2, MySql, Php7.2 Composer installation        "
	echo "------------------------------------------------------------------"

	apt install -y apache2

	apt install -y php7.2 php7.2-common php7.2-curl php7.2-pdo php7.2-mysql php7.2-opcache php7.2-xml php7.2-gd php7.2-mysql php7.2-intl php7.2-mbstring php7.2-bcmath php7.2-json php7.2-iconv php7.2-soap php7.2-zip php7.2-xsl -y

	apt install -y composer

	apt install -y mysql-server mysql-common mysql-client

	rm /etc/php/7.2/cli/php.ini
	cp /etc/php/7.2/apache2/php.ini /etc/php/7.2/cli/

	systemctl enable apache2
	systemctl enable mysql
}

configure_php(){

	echo "------------------------------------------------------------------"
	echo "                        PHP Configuration        "
	echo "------------------------------------------------------------------"

	phpenmod bcmath ctype curl dom gd iconv intil mbstring openssl pdo_mysql SimpleXML soap xsl zip libxml

	sed -i "s/memory_limit =.*/memory_limit = $PHP_MEMORY_LIMIT/g"  "/etc/php/7.2/apache2/php.ini"
	sed -i "s/upload_max_filesize =.*/upload_max_filesize = $PHP_UPLOAD_MAX_SIZE/g"  "/etc/php/7.2/apache2/php.ini"
	sed -i "s/max_execution_time =.*/max_execution_time = $PHP_MAX_EXECUTION_TIME/g"  "/etc/php/7.2/apache2/php.ini"
	sed -i "s/max_input_time =.*/max_input_time = $PHP_MAX_INPUT_TIME/g"  "/etc/php/7.2/apache2/php.ini"
	sed -i "s/post_max_size =.*/post_max_size = $PHP_POST_MAX_SIZE/g"  "/etc/php/7.2/apache2/php.ini"
	sed -i "s/;opcache.save_comments =.*/opcache.save_comments = $PHP_OPCACHE_SAVE_COMMENTS/g" "/etc/php/7.2/apache2/php.ini"
	sed -i "s/;opcache.enable=.*/opcache.enable=$PHP_OPCACHE_ENABLE/g" "/etc/php/7.2/apache2/php.ini"
	sed -i "s/;date.timezone=.*/;date.timezone=Europe\/Berlin/g" "/etc/php/7.2/apache2/php.ini"

}

configure_apache(){

	echo "------------------------------------------------------------------"
	echo "                      Apache Configuration        "
	echo "------------------------------------------------------------------"

	a2enmod rewrite ssl userdir

	echo    "<Directory /home/*/public_html/>
					Options Indexes FollowSymLinks
					AllowOverride None
					Require all granted
			</Directory>" >> "/etc/apache2/apache2.conf"
}

configure_mysql(){

	echo "------------------------------------------------------------------"
	echo "                      Mysql Configuration        "
	echo "------------------------------------------------------------------"

	mysql --user=root <<_EOF_
		UPDATE mysql.user set authentication_string=password('${MYSQL_ROOT_PASSWORD}') WHERE user='root'
		DELETE FROM mysql.user WHERE user='';
		DELETE FROM mysql.user WHERE user='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
		DROP DATABASE IF EXISTS test;
		DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
		FLUSH PRIVILEGES; 
_EOF_

}	


install_phpmyadmin(){

	echo "------------------------------------------------------------------"
	echo "                     Phpmyadmin Configuration        "
	echo "------------------------------------------------------------------"

	echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PW" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/admin-pass password $PHPMYADMIN_PW" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_DB_PW" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections

	apt-get install -y phpmyadmin

	echo "------------------------------------------------------------------"
	echo "You can visit phpmyadmin at localhost/phpmyadmin"
	echo "User: $MYSQL_MAGENTO_USER PW: $MYSQL_MAGENTO_PASSWORD   "
	echo "------------------------------------------------------------------" 

}

# Install basic software first
install_software
configure_php
configure_apache
configure_mysql
install_phpmyadmin

