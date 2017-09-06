
# Description

Service de webdav , pour le moment support que de 1 virtualhost , voir dans le future.
Mise en place d'une gestion par utilisateur qui sont créer lors de l'initialisation du conteneur, il est aussi possible de définir un point de montage (volume) pour avoir le fichier htpasswd de disponible! 

J'utilise le conteneur officiel httpd de docker.

# Utilisation

* Avec le docker-compose 

```
version: '2'
services:
    x3-webdav:
        image: registry.dck.x3rus.com/xerus/x3-webdav
        build: .
        container_name : 'x3-webdav-t'
        hostname: webdav.x3rus.com
        environment:
            - TERM=xterm
            - TZ=America/Montreal
            - USERS_PASS=user1=toto user2=titi
        volumes:
            -  /tmp/webdavUpload:/usr/local/apache2/uploads    # uid=33(www-data)
            -  /tmp/htpasswd-webdav:/usr/local/apache2/user.passwd
 
```
