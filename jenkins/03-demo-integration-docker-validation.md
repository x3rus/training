
## Cas d'utilisation , conteneur docker

Nous avons vue la mise en place de Jenkins, la mise en place d'un serveur apache pour la sécurisation , l'intégration "SIMPLE" avec **gitlab** ainsi que la mise en place d'un slave. Bien entendu je pourrai continuer avec des exemples simple, mais j'ai envie d'aller plus loin en présentant des cas d'utilisations que vous pourriez mettre en place. 
Ceci risque de demander plus d'effort de compréhension selon votre niveau, mais on ira pas sur la lune !!! Accrochez vous , posez des questions sur internet ou autour de vous , essayez de l'expliquer à quelqu'un d'autre :P ( parfois ça l'aide) 

Voici la description du "**besoin**" : J'ai plusieurs conteneur que j'ai créé malheureusement faire des changement sur ces derniers est toujours délicat, car j'ai généralement du temps lors de leurs création, mais pour la mise à jour / modification la phase de teste est délicat. Résultat j'ose pas toujours y toucher , car ça marche puis la mise à jour c'est pas indispensable. En d'autre mot je m'expose à des risques de sécurité et je m'auto limite pour la suite. 
La solution mettre en place une système de validation lors de la création pour que le système réalise au moins l'ensemble des testes passant ... Ceci augmentera mon niveau de confiance pour une mise en production. Il faut comprendre, j'ai pas  des environnements de Dev / QA / Pre-prod / prod ... je suis tout seule :P .


Étape haut niveau pour la réalisation :

1. Lors de l'édition du dépôt Git contenant la définition de mes conteneurs qu'une tâches Jenkins ce déclenche
2. Jenkins extrait le dépôt et réalise une validation "syntaxique" et build le nouveau conteneur ( stop s'il y a un problème )
3. Si le nouveau conteneur à pu être créé avec succès réalisation de teste d'intégration / unit test
4. Si les testes sont un succès envoie du conteneur dans le registry privé docker ( Nous ne l'avons pas encore .... On le couvrira rendu là ou pas comme d'habitude :P )


### Requis pour la réalisation et contrainte 


Donc pour la réalisation de cette opération nous aurons besoin :

* Un slave qui a docker 
* Serveur gitlab 
    * avec des branches .
    * La configuration d'un webhook pour déclencher un build automatiquement.
    * Jenkins devra mettre à jour le dépôt suite au build.
    * Gestion des tags pour fixé une version.

Bien entendu l'ensemble avec des conteneurs.

Bon, nous parlons souvent de résistance au changement, nous prônons l'évolution, le changement des méthodes de travailles , etc . Dans la réalité j'ai été réfractaire dans le changement dans cette situation . Je l'assume pleinement, mais le bon côté nous/vous  pourrons/pourrez capitalisé sur ce travail. 
Je n'ai pas voulu changer l'organisation des mes conteneurs , aujourd'hui comme présenté j'ai un dépôt nommé **dockers** qui contient l'ensemble de la définition de mes conteneurs ( Jenkins, gitlab, webdav, .... ). J'ai donc UN sous-répertoire par conteneur.

```
dockers 
    |> x3-webdav
        |> Dockerfile
    |> x3-jenkins
        |> Dockerfile
    |> x3-gitlab
        |> Dockerfile
    |> ...
```

Il aurait été BEAUCOUP , mais BEAUCOUP plus facile de créer un projets par conteneur dans gitlab pour faire l'opération qui suit, je soulèverai les points quand on va le voir mais j'ai du faire un script pour la gestion. 


### Mise en place du slave avec la capacité de Docker

Plusieurs méthodes sont possible il existe un plugin dans Jenkins pour gérer les serveurs dockers , la communication ce fait via l'API de dockers qui peut être en TLS bien entendu. Je n'ai pas utiliser cette méthode, car dans la réalité je n'ai qu'un serveur docker de "production". Donc je n'ai pas voulu ouvrir le port de l'API de docker pour simplement faire un build et run ... Est-ce que j'aurais dû ?!?! Je pense qu'il y a des arguments pour , mais mon argument dans la situation est plus de gardé ça simple, voir simpliste :D .

![](./imgs/kiss.jpg)


Nous allons donc ajouter un autre conteneur slave pour la partie docker , bien entendu si vous avez une machine dédié pour faire l'opération pas besoin de vous prendre la tête simplement définir l'accès ssh de la machine . Vous assurer que la machine à bien docker et que l'ensemble fonctionne avec l'utilisateur associé à Jenkins .

Donc nous allons faire la modification suivante dans le [docker-compose.yml](./dockers/docker-compose-slabe-dck.yml)

```
[ ... OUTPUT COUPÉ ...]
    jenkins:
        image: jenkins/jenkins
        container_name : 'x3-jenkins-f'
        hostname: jenkins.train.x3rus.com
        environment:
            - TZ=America/Montreal
        volumes:
            - "/srv/docker/x3-jenkins-f/jenkins-data:/var/jenkins_home"
        links:
            - gitlab:gitlabsrv
            - jenkins-slave:jenkins-s1
            - jenkins-slave-dck:jenkins-s2
[ ... OUTPUT COUPÉ ...]
    jenkins-slave: 
        image: x3-jenkins-slave
        build: ./jenkins-slave/.
        container_name : 'x3-jenkins-slave-f'
        hostname : jenkins-slave.train.x3rus.com
        environment:
            - TZ=America/Montreal
        links:
            - gitlab:gitlabsrv 
    jenkins-slave-dck: 
        image: x3-jenkins-slave
        build: ./jenkins-slave/.
        container_name : 'x3-jenkins-slave-dck-f'
        hostname : jenkins-slave-dck.train.x3rus.com
        environment:
            - TZ=America/Montreal
        links:
            - gitlab:gitlabsrv 
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
            - /usr/bin/docker:/usr/bin/docker
[ ... OUTPUT COUPÉ ...]
```

Si nous regardons les 2 définitions des slaves elles sont presque pareille, sauf que le slave pour docker a la définition pour des volumes 

* **/var/run/docker.sock** : Socket pour les communications avec l'applicatif docker 
* **/usr/bin/docker** : Applicatif docker , binaire pour faire des opérations ...

De plus nous ajoutons le lien entre Jenkins et le nouveau slave.

C'est vraiment magnifique d'avoir rien d'autre a mettre en place pour qu'un conteneur soit en mesure d'utiliser docker DANS un conteneur :D , oui oui magie !!! Là on peut dire que c'est bien fait !! 

Pour les petits malin il y a un problème dans la configuration :P , ça marcherai PRESQUE , si vous avez envie d'analyser le problème je vous dis arrêter tout de suite et chercher le problème ... :D Nous pourrions voir ça comme un exercice . Nous allons mettre en place une tâche qui va utiliser ce conteneur et voir la problématique !!!


```bash
$ docker-compose up -d 
Starting x3-gitlab-f ... 
Starting x3-gitlab-f ... done
Starting x3-jenkins-slave-f ... 
Starting x3-jenkins-slave-f
Starting x3-jenkins-slave-f ... done
Creating x3-jenkins-slave-dck-f ... done
Recreating x3-jenkins-f2 ... 
Recreating x3-jenkins-f2 ... done
Recreating x3-jenkins-apache-f2 ... 
Recreating x3-jenkins-apache-f2 ... done
```

Donc même chemin que pour un slave "normale" **manage jenkins** --> **Manage Nodes** --> **add node** .
Comme nous avons déjà un node très similaire je vais réaliser une copie de la configuration puis la modifier ... 

![](./imgs/16-01-use-case-add-docker-slave.png)

J'ai donc modifier :

* La description 
* les étiquettes ( Label )
* le nom du host pour la connexion :D

![](./imgs/16-02-use-case-add-docker-slave-label.png)


Et voilà succès :D

![](./imgs/16-03-use-case-add-docker-slave-status.png)


Réalisons une tâche pour valider que ça fonctionne , mais ça marchera pas :P !! 

![](./imgs/16-04-use-case-test-slave-docker.png)

Section général , l'important dans cette section est vraiment l'utilisation du **label** docker:

![](./imgs/16-05-use-case-test-slave-docker-general.png)

Juste un petit docker __ps__ pour valider que la communication fonctionne !

![](./imgs/16-05-use-case-test-slave-docker-build-def.png)

Je lance le build , bon c'est vraiment drôle, car ce n'était pas l'erreur que je pensait avoir :P , on arrête pas le plaisir :D

![](./imgs/16-05-use-case-test-slave-docker-run.png)

#### Analyse erreur du slave

Bon rendu là je vais faire une section pour le correctif, car il y a au moins 2 problème , pour faire l'analyse du problème je vais me connecter dans le conteneur pour faire l'analyse .

L'erreur indique un problème avec les librairies partagé définie dans le binaire docker, je vais donc analyser s'il y a d'autre librairie manquante :

```bash
$ docker exec -it x3-jenkins-slave-dck-f bash
root@jenkins-slave-dck:/# apt-cache search ^C
root@jenkins-slave-dck:/# ldd /usr/bin/docker 
        linux-vdso.so.1 =>  (0x00007fff21ff8000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f40456c0000)
        libltdl.so.7 => not found
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f40452f7000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f40458dd000)
```

C'est bon signe il n'y en a pas d'autre , installation de la librairie

```bash
root@jenkins-slave-dck:/# apt-cache search ltdl
libltdl-dev - System independent dlopen wrapper for GNU libtool
libltdl7 - System independent dlopen wrapper for GNU libtool
root@jenkins-slave-dck:/# apt-get install libltdl7
```

Comme je suis connecter validons que ça fonctionne : 

```bash
root@jenkins-slave-dck:/# docker  ps   
CONTAINER ID        IMAGE                     COMMAND                  STATUS                    PORTS                     NAMES
aae1b1a50383        x3-jenkins-front          "httpd-foreground"       Up 19 minutes             80/tcp                    x3-jenkins-apache-f
b8b77e2e8ea5        jenkins/jenkins           "/bin/tini -- /usr..."   Up 19 minutes             8080/tcp, 50000/tcp       x3-jenkins-f
ce21f1aa8efc        x3-jenkins-slave          "/usr/sbin/sshd -D"      Up 19 minutes             22/tcp                    x3-jenkins-slave-dck-f
a609350d6cd3        x3-jenkins-slave          "/usr/sbin/sshd -D"      Up 19 minutes             22/tcp                    x3-jenkins-slave-f
b99c5fdcfde1        gitlab/gitlab-ce:latest   "/assets/wrapper"        Up 19 minutes (healthy)   22/tcp, 80/tcp, 443/tcp   x3-gitlab-f
```

Bon faudra modifier la définition du conteneur, mais ça fonctionne avant de changer le Dockerfile , validons que la tâche fonctionne :D 
C'est bien maintenant j'ai l'erreur attendu :D :

![](./imgs/16-05-use-case-test-slave-docker-run-2.png)

Pourquoi, il y a ce problème de permissions ?? En fait le problème dans la définition de notre conteneur , l'exécution des commandes est réalisé avec l'utilisateur jenkinbot . Cependant l'utilisateur n'est pas membre du groupe docker donc le binaire __docker__ n'est pas en mesure d'établir une connexion au docker .

```bash
$ ls -l /var/run/docker.sock
srw-rw---- 1 root docker 0 Sep  1 17:05 /var/run/docker.sock

$ ls -ln /var/run/docker.sock 
srw-rw---- 1 0 994 0 Sep  1 17:05 /var/run/docker.sock 
```

Nous allons donc modifier la définition du conteneur pour ajouter **jenkinbot** au groupe dockers.

Résultat [Dockerfile](./dockers/jenkins-slave/Dockerfile-v2):

```
 # package 

 # Create default user "jenkinbot" with password toto
 # Ajout du groupe docker pour communiquer avec le docker host
 RUN useradd -s /bin/bash -m  jenkinbot && \
     echo "jenkinbot:toto" | chpasswd && \
     groupadd -g 994 docker && \
     usermod -G sudo,docker jenkinbot
```

On reconstruit l'image et on redémarrage le tous :D.

```bash
$ docker-compose build jenkins-slave-dck
[... OUTPUT COUPÉ ...]
Step 11/12 : EXPOSE 22                 
 ---> Running in af3c4aae8318          
 ---> 2a3a863af8ac                     
Removing intermediate container af3c4aae8318                                   
Step 12/12 : CMD /usr/sbin/sshd -D     
  ---> Running in 9bbd1e434c1e          
  ---> 718bdc09cca0                     
Removing intermediate container 9bbd1e434c1e                                   
Successfully built 718bdc09cca0        
Successfully tagged x3-jenkins-slave:latest 

$ docker-compose rm jenkins-slave-dck
Going to remove x3-jenkins-slave-dck-f
Are you sure? [yN] y
Removing x3-jenkins-slave-dck-f ... done

```

Validation de la configuration :

```
$ docker exec x3-jenkins-slave-f id jenkinbot
uid=1000(jenkinbot) gid=1000(jenkinbot) groups=1000(jenkinbot),27(sudo),994(docker)
```

Résultat à l'exécution de notre tâche :

![](./imgs/16-05-use-case-test-slave-docker-run-3-success.png)

### Création de la tâche intégration Gitlab , compilation de l'image Docker

Je sais maintenant on maîtrise l'intégration __gitlab__, mais on va juste faire une révision .
Voici ce que nous allons faire dans cette section :

1. Création de la tâche qui nous servira par la suite 
2. Récupération du dépôt avec la définition du conteneur
3. Compilation d'une image docker avec la définition extraite du dépôt 

Nous allons encore utiliser la tâche de type **FreeStyle** nous aurons les coudés franches .

![](./imgs/17-01-use-case-create-tache-1.png) 

Lors de la présentation j'avais déjà un dépôt **git** pour des conteneurs :

![](./imgs/17-02-use-case-gitlab-docker-depot-index.png)

Je vais donc ajouter l'utilisateur **robot** pour qu'il soit en mesure de communiquer avec ce dépôt .

![](./imgs/17-02-use-case-gitlab-docker-setting-members.png)

Je vais ajouter une définition docker dans le dépôt pour avoir du matériel à compiler ( générer l'image )

```bash
$ git clone http://thomas@git.training.x3rus.com/sysadmin/dockers.git 
Cloning into 'dockers'...
Password for 'http://thomas@git.training.x3rus.com': 
remote: Counting objects: 18, done.
remote: Compressing objects: 100% (13/13), done.
remote: Total 18 (delta 2), reused 0 (delta 0)
Unpacking objects: 100% (18/18), done.

$ mkdir x3-webdav && cd x3-webdav
$ ls
docker-compose.yml  Dockerfile  README.md  scripts

$ cd .. && git add x3-webdav
$ git commit -a -m "Ajout du conteneur webdav"
$ git push origin master
```

[Fichier tar.gz](./data/x3-webdav-basic.tar.gz) contenant le contenue du docker.

Donc nous avons une définition d'image disponible , et l'utilisateur **robot** peut y accéder ! 

Ajoutons ceci dans la définition de notre tâche :

![](./imgs/17-03-use-case-create-config-gitlab.png)

N'oubliez pas la restriction d'exécution :

![](./imgs/17-03-use-case-create-config-label-restriction.png)

On met une définition juste pour être certain que ça passe quelque chose de simple :

![](./imgs/17-03-use-case-create-build-def.png)

On exécute et on admire :D 

![](./imgs/17-03-use-case-create-build-validation-1-success.png)

Donc nous sommes en mesure d'en Jenkins de réaliser la compilation d'une image docker sans problème . 
Nous voulions être aussi en mesure de réaliser un validation de notre image lors de la compilation , en d'autre mot un test unitaire.


### Création d'un système de validation du conteneur

Lors de la présentation DevOps j'avais insisté sur l'aspect de validation , de mise en place de teste unitaire préalable au déploiement. J'avais mentionné que ceci est principalement du côté du développement. Pour ce qui est des testes unitaire effectivement c'est plus pour l'équipe de développement par contre le côté test d'intégration nous incombe . Prenons l'exemple d'un conteneur pour le service **webdav**, quelle type de validation puis je réaliser ?

Pour rappel un service **webdav** est : 

> WebDAV (Web-based Distributed Authoring and Versioning) est un protocole (plus précisément, une extension du protocole HTTP) défini par le groupe de travail IETF du même nom. Décrit dans la RFC 49181, WebDAV permet de simplifier la gestion de fichiers avec des serveurs distants. Il permet de récupérer, déposer, synchroniser et publier des fichiers (et dossiers) rapidement et facilement. L'objectif principal de WebDAV est de rendre possible l'écriture à travers le web et pas seulement la lecture de données. WebDAV permet à plusieurs utilisateurs d'éditer le contenu d'un dossier web simultanément. Il saura gérer les droits d'accès aux fichiers (ou dossiers), en verrouillant momentanément les fichiers et dossiers édités.

Référence : [wikipedia webdav](https://fr.wikipedia.org/wiki/WebDAV)

Voici ce que nous allons valider, j'ai mis en place une liste de validation sur mon conteneur qui sont regroupés par type , je vais lister à haut niveau les validation. Bien entendu ceci évoluera dans le temps avec l'ajout de fonctionnalités

* TestWebDavContainer : Test sur le conteneur webdav avec une utilisateur valide ...
    * setUp : Initialisation pour le début du test , définition URL , utilisateur , mot de passe, ...
    * 01_CreateDirectory : Création d'un répertoire 
    * 02_UploadFile : Upload d'un fichier dans le répertoire
    * 03_ListDirectoy : Liste les fichiers contenu dans le répertoire 
    * 04_DownloadFile : Téléchargement du fichier et validation du hash afin de valider que le fichier est le même que lors de l'envoie
    * 05_BadLoginGetFile : Récupération d'un fichier qui n'existe pas 
* TestWebDavContainerBadLogin : Test sur le conteneur webdav avec une erreur d'authentification , l'ensemble des testes si dessus ne doivent PAS fonctionner.
    * setUp : Initialisation pour le début du test , définition URL , utilisateur , ...
    * 01_CanNotCreateDirectory : Création d'un répertoire alors que l'authentification est mauvaise
    * 02_CanNotListFile : Récupération de la liste des fichiers 
* TestWebDavContainerAnonymous : Test du le conteneur webdav en mode anonyme, l'ensemble des testes ne doivent pas fonctionner.
    * setUp : Initialisation pour le début du test , définition URL .
    * 01_CanNotCreateDirectory : Création d'un répertoire en mode anonyme 
    * 02_CanNotListFile : Liste des fichiers disponible.


Comme vous pouvez le voir il y a 3 bloques selon la situation , chaque bloque comprend une initialisation de l'environnement et des testes . 
Le script python est [data/webdav-validation.py](./data/webdav-validation.py) 

Lors de la présentation de la formation sur YouTube je prendrais un peu de temps pour décortiquer le scripts !

Ce script peut être utilisé de n'importe quelle manière , si vous regardez le script comprend la variable avec l'URL :

```python
 #############
 # Variables #
URL = "http://webdav"

```

Mais comme on aime les conteneurs, franchement à outrance pourquoi ne pas mettre ce script dans un conteneur :D , résultat un aura un conteneur qui valide un conteneur :P . Bon si vous me dites ou mais qui valide le conteneur qui valide le conteneur ... je rigole et ne répond pas :P .

#### Conteneur de validation pour webdav (x3-webdav-cli)


