# Automatic Lamp Stack installer and Magento 2 downloader

### Tested on Ubuntu 18.04 only

This repo provides the skripts to automatically install the most recent versions of MySQL, Apache2, PHP7.2 and Phpmyadmin.


>Please note: the Scripts have not been tested in a production enviroment. Although mysql_secure_installation is executed and the Apache config is safe there is no gurantee for safe production use. All configurations must be checked.


>Phpmyadminn security: It is recommended to secure Phpmyadmin with .htaccess, follow this [guideline](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-18-04) or [Redirect](https://httpd.apache.org/docs/2.4/rewrite/remapping.html) traffic via Apache2.


## Troubles with composer download

Generate your own set of public and private keys [here](https://marketplace.magento.com/customer/accessKeys/).
Change the `auth.json` file, use the your public-key as Username and Private Key as Password

## Quick start

It is only recommended to use these skripts on a fresh Ubuntu 18.04 Installation. The easiest way to start:

~~~
$ sudo bash install.sh -dev
~~~

or 

~~~
$ sudo bash install.sh -prod
~~~


If you are running into problems because of already existing installations run the uninstall skript and reboot the system.

~~~
$ sudo bash uninstall.sh
~~~

Enable SSL with your Certbot provided Certificated

~~~
$ sudo bash enable_ssl.sh
~~~


Edit the env File according to your needs
~~~
MAGENTO_DOMAIN=example.com

MYSQL_HOST=localhost
MYSQL_ROOT_PASSWORD=testpassword
MYSQL_MAGENTO_USER=magento
MYSQL_MAGENTO_PASSWORD=magento_pw
MYSQL_MAGENTO_DATABASE=magento
MYSQL_MAGENTO_PREFIX=mg_

PHPMYADMIN_APP_PW=myadminPw
PHPMYADMIN_PW=myadminPw
PHPMYADMIN_DB_PW=myadminPw

#Options build for Certbot
SSL_CERTIFICATE_FILE = /etc/letsencrypt/live/example.com/cert.pem
SSL_CERTIFICATE_KEY_FILE =/etc/letsencrypt/live/example.com/privkey.pem
SSL_CERTIFICATE_CHAIN_FILE= /etc/letsencrypt/live/example.com/chain.pem

PHP_MEMORY_LIMIT=1024M
PHP_POST_MAX_SIZE=20M
PHP_UPLOAD_MAX_SIZE=50M
PHP_MAX_EXECUTION_TIME=300
PHP_MAX_INPUT_TIME=300
PHP_OPCACHE_SAVE_COMMENTS=1
PHP_OPCACHE_ENABLE=1
~~~