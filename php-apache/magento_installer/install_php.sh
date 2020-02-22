#!/bin/bash



apt install -y php7.2 php7.2-common php7.2-curl php7.2-pdo php7.2-mysql php7.2-opcache php7.2-xml php7.2-gd php7.2-mysql php7.2-intl php7.2-mbstring php7.2-bcmath php7.2-json php7.2-iconv php7.2-soap php7.2-zip php7.2-xsl

cp /opt/docker/etc/php/php.ini /etc/php/7.2/apache2/

phpenmod bcmath ctype curl dom gd hash iconv intl mbstring openssl pdo_mysql SimpleXML soap xsl zip libxml

