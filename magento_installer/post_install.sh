#!/bin/bash

chown www-data:www-data -R /var/www/magento2

set_mode(){

    if [ $1 == "-dev" ]; then
        /var/www/magento2/bin/magento deploy:mode:set developer
        chmod 777 -R /var/www/magento2
    fi

    if [ $1 == "-prod" ]; then 
        /var/www/magento2/bin/magento deploy:mode:set productio
        find /var/www/magento2/app/code /var/www/magento2/var/view_preprocessed /var/www/magento2/vendor /var/www/magento2/pub/static /var/www/magento2/app/etc /var/www/magento2/generated/code /var/www/magento2/generated/metadata \( -type f -or -type d \) -exec chmod u-w {} + && chmod o-rwx /var/www/magento2/app/etc/env.php && chmod u+x /var/www/magento2/bin/magento
    fi
}