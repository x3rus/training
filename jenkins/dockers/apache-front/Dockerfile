#
# Description : Apache Proxy Frontend for Jenkins
#
# Author : Thomas.boutry@x3rus.com
# Licence : GPLv3 ou plus
#
###########################################################

FROM httpd:2.4
MAINTAINER Thomas Boutry "thomas.boutry@x3rus.com"

# Enable Proxy , SSL and rewrite modules  configuration
RUN sed -i 's/#LoadModule proxy_module modules\/mod_proxy.so/LoadModule proxy_module modules\/mod_proxy.so/g; \
         s/#LoadModule proxy_connect_module modules\/mod_proxy_connect.so/LoadModule proxy_connect_module modules\/mod_proxy_connect.so/g; \
         s/#LoadModule proxy_http_module modules\/mod_proxy_http.so/LoadModule proxy_http_module modules\/mod_proxy_http.so/g; \
         s/#LoadModule rewrite_module modules\/mod_rewrite.so/LoadModule rewrite_module modules\/mod_rewrite.so/g; \
         s/#LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so/LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so/g; \
         s/#LoadModule ssl_module modules\/mod_ssl.so/LoadModule ssl_module modules\/mod_ssl.so/g;'  /usr/local/apache2/conf/httpd.conf


# Copie jenkins configuration file and include it in the httpd.conf
COPY conf/jenkins.conf /usr/local/apache2/conf/jenkins.conf
RUN echo "Include conf/jenkins.conf" >> /usr/local/apache2/conf/httpd.conf

RUN mkdir /usr/local/apache2/ssl/
COPY conf/ssl/* /usr/local/apache2/ssl/

# Validation de la configuration
RUN /usr/local/apache2/bin/apachectl configtest

