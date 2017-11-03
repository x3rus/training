## Mise en place de la base [Pratique] 

Nous allons voir un peu la base de la configuration du serveur et de la communication avec 2 agents, bien entendu pour faciliter ma présentation de je vais utiliser des conteneurs docker. Ici je vais utiliser des conteneurs docker pour simuler des machines virtuel ou physique , l'utilisation de puppet dans un conteneur n'est pas claire pour moi. En fait je ne crois pas que puppet soit approprié , car nous avons l'ensemble de la définition du conteneur dans un fichier plan ( Dockerfile ) . 

Cependant il est toujours possible d'orchestrer vos conteneurs avec puppet , ce ne sera pas couvert dans la formations puppet , on fera peut-être une capsule sur le sujet ou PAS :P . Je vous donne donc des liens à consulter :

* https://docs.docker.com/engine/admin/puppet/#containers
* https://github.com/garethr/garethr-docker

Autre lien qui semble intéressant, mais je n'ai pas approfondie , prendre note de l'avertissement au début :P , https://github.com/vshn/puppet-in-docker

Pour les personnes qui connaisse déjà puppet 3.8  mais qui sont à la recherche d'un rafraichissement de connaissance prenez le temps de prendre connaissance de la page : https://docs.puppet.com/puppet/5.2/whered_it_go.html car puppet à réalisé plusieurs modification dans la structure de fichier.

### Utilisation de Docker pour le serveur

La partie serveur s'applique toujours pour la mise en place du serveur , nous allons donc utiliser le conteneur officiel de Puppet disponible sur docker hub : https://hub.docker.com/r/puppet/puppetserver/

Sur le [github de puppetlab](https://github.com/puppetlabs/puppet-in-docker-examples/tree/master/compose) nous trouvons un dockers compose très complet, pour la mise en place de puppet avec l'ensemble des composantes. 

Je suis donc partie de cette configuration en réalisant quelque modification bien entendu :D. Voici donc le résultat "finale" pour le moment de la configuration : [docker-compose.yml](./dockers/puppet-server/docker-compose-v1.yml) 

```
version: '2'

services:
  puppet:
    container_name: x3-puppet-f
    hostname: puppet
    image: puppet/puppetserver
    # ports:
    #  - 8140
    volumes:
      - /srv/docker/x3-puppet-f/code:/etc/puppetlabs/code/
      - /srv/docker/x3-puppet-f/puppet/ssl:/etc/puppetlabs/puppet/ssl/
      - /srv/docker/x3-puppet-f/puppet/serverdata:/opt/puppetlabs/server/data/puppetserver/
    links:
      - puppetdb:puppetdb

  puppetdbpostgres:
    container_name: x3-puppet-postgresdb-f
    image: puppet/puppetdb-postgres
    environment:
      - POSTGRES_PASSWORD=puppetdb
      - POSTGRES_USER=puppetdb
    #expose:
      #- 5432
    volumes:
      - /srv/docker/x3-puppet-f/puppetdb-postgres/data:/var/lib/postgresql/data/

  puppetdb:
    hostname: puppetdb
    image: puppet/puppetdb
    container_name: x3-puppet-db-f
    #ports:
    #  - 8080
    #  - 8081
    volumes:
      - /srv/docker/x3-puppet-f/puppetdb/ssl:/etc/puppetlabs/puppet/ssl/
    links:
      - puppetdbpostgres:postgres

  puppetboard:
    image: puppet/puppetboard
    #ports:
    #  - 8000

  puppetexplorer:
    image: puppet/puppetexplorer
    #ports:
    #  - 80
    read_only: true
```

Bon voilà on a la définition de puppet , pour ceux qui ont utilisé les veilles version de puppet le premier réflexe est **woww** c'est quoi tous ça , moi j'avais juste le puppetmaster puis ça fonctionné très bien. Effectivement nous aurions pu mettre uniquement le service puppetmaster, mais on va allé un peu plus loin. Même avec la version 3.8 auquel je vais faire référence tous au long de la présentation il était possible de mettre en combinaisons puppetmaster avec puppetdb , ... Mais comme nous avions pas docker c'était un peu pénible. Docker nous offrant une plus grande facilité de combiner l'ensemble autant en profiter. 

#### liste et description des composantes

Prenons quelques minutes juste pour voir les composantes :

* __puppetserver__ : Ceci est donc le puppet master , l'ensemble des machines devront être en mesure de communiquer avec ce conteneur via le port 8140 , l'ensemble de la configuration du système sera dans ce conteneur. Il est le point central de l'ensemble du système sans lui plus de puppet.
* __puppetdb__ : Ce conteneur nous permettra de conserver l'ensemble des données du serveur puppet de manière structure, ceci permettra à d'autre application satellite d'extraire les données de puppet pour les manipuler si requis.  
* **puppetdb-postgres** : Ce conteneur est le backend de puppetdb :P , car puppetdb est un service par défaut  je crois qu'il stock les informations avec sqlite mais ça ne scale pas . Ici nous utilisons postgress pour faire le stockage des informations.
* **puppetboard** : Nous aurons la chance d'avoir une visualisation de l'état du système puppet , ce conteneur établira une connexion au conteneur puppetdb est réalisera une présentation de l'état de santé du système. Est-ce que les machines communique bien avec le serveur , ...
* **puppetexplorer** : Ce conteneur permet d'explorer les données dans la base de donnée puppetdb facilement, contrairement au puppetboard qui offre une visualisation structurer , puppet explorer vous permet de voir les données sans traitement.

# NOTE :

* type langage https://docs.puppet.com/puppet/5.2/type.html

* __Puppet IDE__ : https://puppet.com/blog/geppetto-a-puppet-ide 


