FROM ubuntu:18.04

LABEL maintainer="Ara K."

ENV DOCKER_DIR /opt/docker/
ENV INSTALLER_DIR ${DOCKER_DIR}/magento_installer
ENV COMPOSER_HOME /var/www/.composer/


# Install apache2
COPY ./magento_installer ${INSTALLER_DIR}
COPY ./sites-available ${DOCKER_DIR}/apache2/sites-available

RUN apt-get update
RUN apt-get -y install curl
RUN apt-get -y install git 
RUN cd $INSTALLER_DIR \
    && bash install_apache.sh \
    && bash install_php.sh


# Install php
RUN curl -sS https://getcomposer.org/installer | \
    && mv composer.phar /usr/local/bin/composer
COPY ./auth.json $COMPOSER_HOME

RUN rm -r $INSTALLER_DIR