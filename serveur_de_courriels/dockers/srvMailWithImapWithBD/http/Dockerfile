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

# Copie l'application postfix adm
COPY docroot/postfixadmin-2.3.8/ /var/www/html/

# Copie la configuration en format Jinja2
COPY conf/config.inc.php.j2 /root/

# script pour la substitution
ADD run.sh /

CMD ["/run.sh"]

