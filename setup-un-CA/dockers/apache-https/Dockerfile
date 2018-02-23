# Description : simple conteneur ubuntu pour avoir un apache , avec comme base ubuntu
#               ne pas utiliser ce conteneur pour une utilisation réelle mon objectif
#               est vraiment d'avoir un Ubuntu pour la démonstration
# 
# Author : Thomas Boutry <thomas.boutry@x3rus.com>

FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y apache2 apache2-utils vim && \
    apt-get clean 

RUN mkdir /var/lock/apache2

# Unable mod_ssl
RUN cd /etc/apache2/mods-enabled && \
    ln -s ../mods-available/ssl.load . && \
    ln -s ../mods-available/socache_shmcb.load . && \
    ln -s ../mods-available/ssl.conf .

# Creation du repertoire de base pour le site
RUN mkdir /var/www/html/toto.x3rus.com/

# COPIE fichier de site web 
COPY data/index.html /var/www/html/toto.x3rus.com/index.html

# COPIE configuration
COPY data/*.conf /etc/apache2/sites-available/

# Activation du site web en http sans le chiffrement
RUN cd /etc/apache2/sites-enabled/ && \
    ln -s ../sites-available/toto.x3rus.com.conf . && \
    apachectl configtest
 
CMD ["/usr/sbin/apache2","-DFOREGROUND"]
