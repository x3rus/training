#
# Description : Service webdav , définition des utilisateurs avec Variable $USERS_PASS ou
#               une volume pour le fichier /usr/local/apache2/user.passwd . PAS de vhost
#               Répertoire d'upload /usr/local/apache2/uploads (UID 33)
#
# Author : Thomas.boutry@x3rus.com
# Licence : GPLv3 ou plus
#

FROM httpd:2.4
MAINTAINER Thomas Boutry "thomas.boutry@x3rus.com"

# Enable Webdav modules and configuration
RUN sed -i 's/#LoadModule dav_module modules\/mod_dav.so/LoadModule dav_module modules\/mod_dav.so/g; \
         s/#LoadModule dav_fs_module modules\/mod_dav_fs.so/LoadModule dav_fs_module modules\/mod_dav_fs.so/g; \
         s/#LoadModule dav_lock_module modules\/mod_dav_lock.so/LoadModule dav_lock_module modules\/mod_dav_lock.so/g; \
         s/#LoadModule auth_digest_module modules\/mod_auth_digest.so/LoadModule auth_digest_module modules\/mod_auth_digest.so/g; \
         s/#Include conf\/extra\/httpd-dav.conf/Include conf\/extra\/httpd-dav.conf/g' /usr/local/apache2/conf/httpd.conf                         


# Change setup to authorize all valide users
RUN sed -i 's/Require user admin/Require valid-user/g' /usr/local/apache2/conf/extra/httpd-dav.conf &&  \
    sed -i 's/AuthType Digest/AuthType Basic/g' /usr/local/apache2/conf/extra/httpd-dav.conf && \
    sed -i 's/Require method GET POST OPTIONS//g' /usr/local/apache2/conf/extra/httpd-dav.conf && \
    sed -i 's/AuthDigestProvider file/Options Indexes/g' /usr/local/apache2/conf/extra/httpd-dav.conf 
    

RUN cat /usr/local/apache2/conf/extra/httpd-dav.conf

RUN mkdir /usr/local/apache2/uploads /usr/local/apache2/var \
    && chown daemon /usr/local/apache2/uploads /usr/local/apache2/var

# Validation de la configuration
RUN /usr/local/apache2/bin/apachectl configtest

# Volume required
# /usr/local/apache2/user.passwd
# /usr/local/apache2/uploads

COPY scripts/x3-docker-entrypoint.sh /

ENTRYPOINT ["/x3-docker-entrypoint.sh"]


