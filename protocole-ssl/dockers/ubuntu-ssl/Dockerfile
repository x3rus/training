# Description : simple conteneur ubuntu pour avoir un apache , avec comme base ubuntu
# 
# Author : Thomas Boutry <thomas.boutry@x3rus.com>

FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y apache2 apache2-utils && \
    apt-get clean 

RUN mkdir /var/lock/apache2

CMD ["/usr/sbin/apache2","-DFOREGROUND"]
