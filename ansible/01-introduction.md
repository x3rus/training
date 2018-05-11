
[[_TOC_]]

# Introduction

Telle que présenté lors de l'introduction DevOps , un des principes fondamental et d'être en mesure de déployer les applications rapidement , nous l'avons vu dans le processus de l'intégration continue. En d'autre mot lors d'un changement de code ou sur une base régulière, chaque jour par exemple, nous devons être en mesure de déployer une nouvelle version de l'application. Cette opération doit être réalisé de manière identique, à chaque déploiement, il serait complètement incohérent d'avoir un mécanisme différent à chaque fois. Le requis d'un déploiement rapide n'est pas réellement présent, cependant si vous devez passer 6 heures pour réalisé chaque déploiement manuellement, vous passerez l'ensemble de votre temps à réalisé cette opération. Par le fait même après 2 semaines à réalisé ces opérations répétitive, votre niveau de motivation sera très bas !!

Il existe plusieurs solution de déploiement , **puppet** , **ansible**, **salt** , **cfengin** , ... Je ne vais pas vous dire que **Ansible** est le meilleur , cependant c'est celui qui est très populaire et avec le support de RedHat assure une garantie de stabilité et d'évolution. Par la suite chacun on leur avantage et inconvénient , l'important est d'en maitriser UN par la suite l'apprentissage des autres est plus simple.

Information sur [ansible depuis wikipedia](https://fr.wikipedia.org/wiki/Ansible_\(logiciel\))

> Ansible est une plate-forme logicielle libre pour la configuration et la gestion des ordinateurs. Elle combine le déploiement de logiciels multi-nœuds, l'exécution des tâches ad-hoc, et la gestion de configuration. Elle gère les différents nœuds par-dessus SSH et ne nécessite l'installation d'aucun logiciel supplémentaire à distance sur eux. Les modules fonctionnent grâce à JSON et à la sortie standard et peuvent être écrits dans n'importe quel langage de programmation. Le système utilise YAML pour exprimer des descriptions réutilisables de systèmes.
> 
> La plate-forme a été créée par Michael DeHaan, l'auteur de l'application serveur de provisioning Cobbler et coauteur du cadre de développement Func pour l'administration à distance. Les utilisateurs de Ansible comprennent le Fedora Project, Hewlett-Packard Allemagne, Basho Technologies, ALE International et l'Université Aristote de Thessalonique, ainsi qu'Airbus, La Poste et la Société générale. Il est inclus dans le cadre de la distribution Linux Fedora, propriété de Red Hat inc., et est également disponible pour Red Hat Enterprise Linux, CentOS et Scientific Linux via les paquets supplémentaires "Extra Packages for Enterprise Linux" (EPEL)5.
> 
> Ansible Inc. était la société derrière le développement commercial de l'application Ansible. Red Hat rachète Ansible Inc. en octobre 2015.
> 
> Le nom Ansible a été choisi en référence au terme Ansible choisi par Ursula Le Guin dans ses romans de science-fiction pour désigner un moyen de communication plus rapide que la lumière.

TODO: Ajout de plus d'introduction avec le pull / push des agents 

## Référence :

* [Wikipedia ansible](https://fr.wikipedia.org/wiki/Ansible_(logiciel))

TODO : plus de référence SVP

# Mise en place d'un environnement d'apprentissage avec docker

Afin d'être en mesure de réaliser les exemples , démontrés dans cette documentation nous allons mettre en place un conteneur qui nous permettra de refaire l'ensemble du matériel ci-dessous. 
J'ai choisie de le faire dans un conteneur , afin d'avoir quelques choses de portables, mais aussi ceci offre la possibilité de voir l'ensemble des requis pour que ça fonctionne . Que nous parlions de packages installé ou de fichiers de configuration mis en place.


## Création du conteneur Ansible et validation

* Création de clé ssh ( explication plus loin) 

```bash
$ mkdir dockers/x3-ansible-srv/conf
$ ssh-keygen -b 2048 -f ./id_rsa
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/xerus/.ssh/id_rsa.
Your public key has been saved in /home/xerus/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:znrVBd7Hdzg6/2Jzi5X2AI1xIhCV4oxCL2t5QrWspqU xerus@goishi
The key s randomart image is:
+---[RSA 2048]----+
|        oo..     |
|    . . ... .    |
|   . + = ...oo.o |
|    + = o  ..*= =|
|   . *  S  .oo.oo|
|    O .o  . +.  .|
|   * o  o.   o.+ |
|  E    ..     O.o|
|      ..     o *+|
+----[SHA256]-----+

$ ls         
id_rsa  id_rsa.pub         
```

Vous avez le conteneur disponible x3-ansible-srv : [Dockerfile](./dockers/x3-ansible-srv/Dockerfile)

```
 # pull base image
FROM ubuntu:16.04
MAINTAINER Thomas Boutry <thomas.boutry@x3rus.com>

ENV DEBIAN_FRONTEND=noninteractive 

 # Installation of ansible 
 # J'ai volontairement PAS bloquer l'installation des packages en plus car je veux avoir une conteneur
 # meme s'il est gros ca me derange pas :D
RUN apt-get update -y && \
    apt-get install -y software-properties-common && \
    apt-add-repository -y ppa:ansible/ansible && \
    apt-get update -y && \
    apt-get install -y ansible
    
 # Create user "c3po" with no password
 # Ajout du groupe docker pour communiquer avec le docker host
RUN useradd -s /bin/bash -m  c3po && \
    groupadd automate && \
    usermod -G automate c3po

 # Creation du répertoire ssh pour l'utilisateur
RUN mkdir /home/c3po/.ssh/ && \
    chown c3po:c3po /home/c3po/.ssh && \
    chmod 700 /home/c3po/.ssh/

 # Copie la clef publique pour jenkins 
COPY conf/id_rsa* /home/c3po/.ssh/

 # Fix perms for ssh key
RUN chown c3po:c3po /home/c3po/.ssh/id_rsa* && \
    chmod 700 /home/c3po/.ssh/id_rsa*
   
 # default command: display Ansible version
ENTRYPOINT ["/usr/bin/ansible-playbook"]
CMD ["--version"]

```

Définition du docker-compose [docker-compose.yml](./dockers/x3-ansible-srv/docker-compose.yml): 

```
version: '2'
services:
    ansible:
        image: x3rus/x3-ansible
        build: .
        container_name : 'x3-ansible-p'
        environment:
            - TERM=xterm
        networks:
            - bridge
 #        volumes:
 
networks:
    bridge:
        external: true

 # Exemple d'utilisation avec docker-compose et run :
 # docker-compose run --volume=/tmp/ansible-tmp/:/etc/ansible/  ansible   /etc/ansible/playbooks/setup-dck.yml
 #

```

Création de l'image 

```bash
$ cd dockers/x3-ansible-srv
$ docker-compose build
```

Validation que l'ensemble fonctionne avec des testes simple qui seront expliqué plus tard ...

```bash
$ docker-compose  run --rm ansible 
ansible-playbook 2.5.2
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 2.7.12 (default, Dec  4 2017, 14:50:18) [GCC 5.4.0 20160609]


$ docker-compose  run --rm --entrypoint=/bin/bash ansible
root@1f26260af83d:/# 
root@1f26260af83d:/# 

root@e306f2e83359:/# ansible localhost -m ping
 [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

localhost | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```

## Infrastructure pour l'apprentissage 

Afin d'être en mesure de faire de vraie teste nous allons mettre " l'infrastructure ", disons plus la configuration suivante : 

![](./imgs/infrastructure_for_learning-v1.png)

* **Ansible** : Un conteneur ansible avec l'application et un **volume** pour stocker la configuration.
* **AppServer** : Un conteneur qui nous servira de serveur applicatif , je ne sais pas encore quelle application mais détail.
* **WebServer** : Un conteneur avec un serveur web qui servira de frontal pour le serveur applicatif.
* **DatabaseServer** : Un conteneur pour la Base de donnés .

Les conteneurs AppServer + WebServer + DatabaseServer seront basés sur la même images docker.

Nous utiliserons le mode "original" ou "classique" de Ansible pour la communication avec les nœuds soit le protocole ssh ( port 22 / TCP ) , nous verrons éventuellement d'autre mode telle que l'orchestration des dockers, AWS , voir powershell :P 

Donc la machine **ansible** étalira la connexion via **ssh** , bien entendu nous ne voulons pas avoir à saisir un mot de passe nous utiliserons donc le système de clé publique / privé afin de permettre à la machine de ce connecté sur les noeuds.

TODO : explication pour l'utilisateur c3po et r2d2

## Création de l'image pour la simulation des machines 

Telle que mentionné dans la section précédente nous allons simulé une machine de type VM ou physique, nous allons donc faire une entorse au principe du conteneur et avoir une service OpenSSH en plus du service qui sera déployé . Ansible a un module spécifique pour docker que nous aurons l'occasion de voir assurément cependant je veux le faire en mode "VM" service ssh pour débuter nous passerons à l'autre étape par la suite. 


