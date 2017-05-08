# Thomas Boutry
FROM php:5-apache
MAINTAINER Boutry Thomas <thomas.boutry@x3rus.com>

# Ignore APT warnings about not having a TTY
ENV DEBIAN_FRONTEND noninteractive

# Php Modules a activer 
RUN apt-get update && apt-get install -y  --no-install-recommends libmcrypt-dev python-pip python-wheel python-setuptools \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install pdo_mysql \
    && pip install j2cli

RUN mkdir /var/www/showpi  /var/www/contacts

COPY app/showpi/* /var/www/showpi/
COPY app/contacts/* /var/www/contacts/
COPY conf/001* /etc/apache2/sites-available/

RUN a2ensite 001*
