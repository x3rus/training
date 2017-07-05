# Description

**GitLab Community Edition** est un logiciel libre, sous [licence MIT](https://fr.wikipedia.org/wiki/Licence_MIT). Il s'agit d'une [forge](https://fr.wikipedia.org/wiki/Forge_(informatique)) fonctionnant sur GNU/Linux (Debian, Redhat…).

À l'origine, le produit était nommé **GitLab**. En juillet 2013, le produit est scindé en deux : __GitLab Community Edition__ et __GitLab Enterprise Edition__. Si __GitLab CE__ reste un logiciel libre, __GitLab EE__ passe sous licence propriétaire en février 2014 et contient des fonctionnalités non présentes dans la version CE.

**GitLab CE** est produit par __GitLab B.V.__ puis __GitLab Inc.__ avec un modèle de développement open core.

Site web : [https://about.gitlab.com/](https://about.gitlab.com/)
Site de documentation : [https://docs.gitlab.com/ce/](https://docs.gitlab.com/ce/)

Bon comme toujours on va se concentrer sur la version **LIBRE** , je vous laisserai explorer les fonctionnalités en plus disponible dans la version __commercial__

Vous n'êtes pas obligé d'installer un serveur GitLab si vous désirez l'utiliser vous pouvez aussi vous enregistrer sur le site de gitlab vous créer un compte et l'utiliser comme __GitHub__!

## Fonctionnalité 

Voici la liste des fonctionnalités disponible avec **GitLab**  : [https://about.gitlab.com/features/](https://about.gitlab.com/features/)

Comme nous pouvons voir la solution est **COMPLÈTE**

## Pourquoi GitLab et non PAS GitHub 

__GitHub__ est très bien nous n'enlèverons jamais la puissance du système cependant voici quelques avantage de __GitLab__ :

* GitLab peut être déployé sur VOS serveurs librement
* GitLab permet d'avoir des dépôts privés, GitHub vous permet uniquement d'avoir des dépôts publique gratuitement.


# Installation 

Comme nous aimons dockers l'installation sera réalisé avec docker, honnêtement comme c'est un logiciel __ruby__ c'est assez ennuyant à mettre en place , puis le conteneur fonctionne TELLEMENT bien :D .

Donc nous allons utiliser le fichier de [docker-compose.yml](./docker/docker-compose-v1.yml) :

```
version: '2'
services:
    gitlab:
        image: 'gitlab/gitlab-ce:latest'
    #    restart: always
        container_name : 'x3-gitlab-f'
        hostname: git.training.x3rus.com
        environment:
            TZ: America/Montreal
            GITLAB_OMNIBUS_CONFIG: |
                gitlab_rails['time_zone'] = 'America/Montreal'
                gitlab_rails['gitlab_email_from'] = 'noreply@x3rus.com'
                gitlab_rails['smtp_enable'] = true
        volumes:
            - '/srv/docker/x3-gitlab-f/gitlab/etc:/etc/gitlab'
            - '/srv/docker/x3-gitlab-f/gitlab/logs:/var/log/gitlab'
            - '/srv/docker/x3-gitlab-f/gitlab/data/:/var/opt/gitlab'

```

Vous avez une documentation complète disponible à ici [https://docs.gitlab.com/omnibus/docker/README.html](https://docs.gitlab.com/omnibus/docker/README.html).

L'ensemble de la configuration de gitlab sera initialisé grâce au paramètre définie dans la variable **GITLAB\_OMNIBUS\_CONFIG** :
* Le fuseaux horaire 
* L'adresse de courriel de provenance
* la gestion des sauvegarde
* Permission et rétention des sauvegardes

Comme vous pouvez aussi le constater j'ai quelques répertoire que j'ai exporter du conteneur __gitlab__ , en fait le répertoire **/etc/gitlab** ne serait pas obligatoire , cependant ceci était plus facile pour l'environnement de production pour inclure mon certificat SSL et clé . J'ai aussi voulu conserver mes logs en dehors du conteneur et bien entendu mes données pour les moments de mise à jour du conteneur.

* Donc Démarrage en arrière plan et visualisation des logs

```bash
$ docker-compose up -d && docker-compose logs -f gitlab
Creating network "docker_default" with the default driver
Creating x3-gitlab-f                                                               
Attaching to x3-gitlab-f                                                           
x3-gitlab-f | Thank you for using GitLab Docker Image!
x3-gitlab-f | Current version: gitlab-ce=9.2.5-ce.0                                         
x3-gitlab-f |                              
[ ... ]
x3-gitlab-f | Configuring GitLab...
x3-gitlab-f | 
x3-gitlab-f | 
x3-gitlab-f |   * Moving existing certificates found in /opt/gitlab/embedded/ssl/certs
x3-gitlab-f | 
x3-gitlab-f |   * Symlinking existing certificates found in /etc/gitlab/trusted-certs

[ ... ça prend un peu de temps ... ]
x3-gitlab-f | gitlab Reconfigured!                                                                                                                        
x3-gitlab-f | The latest version 9.6.1 is already running, nothing to do Checking for an omnibus managed postgresql: OK                                    
Checking if we already upgraded: OK                                                                                             
x3-gitlab-f | ==> /var/log/gitlab/redis-exporter/current <==
[ ... ]
```

* Nous allons sur à l'URL de conteneur en __http__ nous devrons définir le mot de passe de l'administrateur (**root**)

![](./imgs/gitlab-01-setup-admin-password.png)

* Par la suite s'authentifier avec le compte **root**, nous avons donc un environnement fonctionnel.

# Configuration 

Configuration de l'environnement **gitlab** , je n'ai pas la prétention d'être un expert, mon objectif est de partager avec vous ma connaissance et ainsi vous faire gagner du temps . Idéalement vous pointer quelques fonctionnalités, que vous n'utilisez pas encore et qui sont vraiment agréable.

L'objectif est principalement une couverture utilisateur avec un peu d'administration.

## Accès au service par les utilisateurs

Premièrement nous allons créer un utilisateur afin de travailler avec ce dernier , comme toujours je n'utilise JAMAIS le compte **root**  sauf quand ceci est requis. Ceci est bien entendu pour des question de sécurité .

Vous l'avez peut-être remarqué par defaut les utilisateurs peuvent se créer eux même des comptes 

![](./imgs/gitlab-02-setup-user-auto-register.png)

Personnellement, j'ai désactivé cette option, car j'aime avoir le contrôle de mes utilisateurs :P , oui je partage mes scripts , etc mais je veux conserver le contrôle :D.

### Désactivation de l'enregistrement autonome des utilisateurs 

* Établir une connexion comme **root** , cliquez sur la clé anglaise puis sélectionnez **setting** 

![](./imgs/gitlab-03-admin-area.png)

* Descendez et décocher l'option **sign-up enable**

![](./imgs/gitlab-04-disable-signUP.png)

### Création d'un utilisateur

* Toujours comme administrateur **root**  et dans la section __admin__ , vous avez le nombre d'utilisateur actuel et un bouton **new user** disponible

* Voici le résultat quand on définie un utilisateur :

![](./imgs/gitlab-05-creation-utilisateur.png)

Comme vous pouvez le constater , vous ne définissez pas le mot de passe de l'utilisateur ce dernier recevra par courriel un lien qu'il pourra suivre afin définir lui même sont mot de passe.

Dans notre configuration actuelle le système ne sera pas en mesure de transmettre le courriel car le serveur de relais n'est pas définie et ma machine n'est pas autorisée à transmettre un courriel directement sur Internet. Ceci va nous offrir l'occasion de voir comment réinitialiser un mot de passe :D


### Réinitialisation d'un mot de passe utilisateur

Toujours comme administrateur , nous éditons l'utilisateur et nous pourrons changer le mot de passe.

![](./imgs/gitlab-06-liste-utilisateur.png)

Et voilà :D

Quand l'utilisateur établira une connexion il devra réinitialisé sont mot de passe 

![](./imgs/gitlab-07-resset-password-by-utilisateur.png)

# Utilisation de gitlab (Utilisateur)

Nous reviendrons éventuellement sur la configuration du service gitlab , mais avant de voir les possibilités voyons l'utilisation simple par la suite nous allons nous créer des "besoins" :P.

## Définition des préférence 

Lors de la première authentification vous aurez le choix de définir vos préférences... Je sais c'est un détail , mais quand c beau comme on l'aime c'est MIEUX :P , on a plus envie de l'utiliser .

![](./imgs/gitlab-08-preference-utilisateur.png)

## Définition de groupe

L'objectif des groupes est de permettre un regroupement de projets dans un groupe , en plus de vous permettre une meilleur organisation de vos projets ceci aura aussi l'avantage de vous permettre d'attribuer des permissions sur un groupe pour d'autre utilisateurs .

Nous allons faire la création de deux groupe afin de voir l'interaction possible entre les groupes :

* sysadmin : contiendra les projets de sysadmin telle que les conteneurs , les scripts développés , ...
* __config__ : ceci contiendra la configuration d'une serveur , des conteneurs , ...

Débutons : 

![](./imgs/gitlab-09-creation-groupe.png)

![](./imgs/gitlab-10-liste-groupes.png)

Passons à la création des projets 

## Définition de projet 

Nous allons donc créer des projets sous le groupe sysadmin et __config__ voici la structure pour les besoins de l'exemple :

* sysadmin:
    * dockers : contient nos définitions "primaire de conteneur" pour le moment ceci contiendra surtout notre définition de __gitlab__
    * scripts : contiendra un ensemble de scripts développé , nous l'utiliserons principalement lors de l'intégration avec jenkins ... Mais voyons pour débuter le concept :D.
* config :
    * __goishi-dockers__ : contient la configuration des conteneurs en exécution , car comme nous réalisons des volumes avec les conteneurs qui contienne des configurations je préfère le conserver dans git.
    * __goishi__ : en réalité je vais pas le faire mais en théorie ceci me permet de conserver la configuration de mon serveur en production donc le **/etc**.

Débutons avec la création des projets , démonstration avec 1 .

![](./imgs/gitlab-11-creation-projet.png)

![](./imgs/gitlab-12-empty-projet.png)

Voici donc le résultat :

![](./imgs/gitlab-13-liste-projets.png)

## Intégration dépôt local vers le serveur 

Ce qui est magnifique une fois le projet créé est que sur la page du projet vous avez l'ensemble des instructions pour vous accompagner pour transmettre votre dépôt local git vers le serveur. 

**CLARIFICATION** : ce cours n'est pas une formation git si vous voulez plus d'information sur ce point, j'ai quelques vidéos dans la formation Linux 202 sur le sujet ! 

Bien que l'ensemble des instructions sont présent je vais les expliquer ici , car je dois transmettre mes fichiers pour la présentation . J'aime bien recréer la structure localement sur ma machine afin d'avoir la même référence que sur le serveur mais libre à vous ceci n'est pas un requis .

```bash
$ mkdir -p  ~/gitlab-demo/sysadmin/dockers
$ mkdir -p  ~/gitlab-demo/sysadmin/scripts
```

* Je vais mettre en place les fichiers pour le conteneur __gitlab__ :

```bash
$ cp -r ~/git/formations/gitlab/docker/ gitlab-demo/sysadmin/dockers/gitlab/
$ ls -R ~/gitlab-demo/sysadmin/dockers/
/home/xerus/gitlab-demo/sysadmin/dockers/:
gitlab

/home/xerus/gitlab-demo/sysadmin/dockers/gitlab:
docker-compose.yml
```

* Envoyons l'ensemble vers le serveur , comme ceci est un nouveau dépôt nous devrons le créer préalablement 

```bash
$ cd ~/gitlab-demo/sysadmin/dockers/
$ git init .
Initialized empty Git repository in ~/gitlab-demo/sysadmin/dockers/.git/
```

* Si vous n'utilisez pas déjà git , initialisé vos informations "client"

```bash
$ git config --global user.name "thomas aka moi"
$ git config --global user.email "unemail@x3rus.com"
```

* Ajout du répertoire __gitlab__ et commit de la modification dans le dépôt local 

```bash
$ git add gitlab/

$ git status
On branch master

Initial commit

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

        new file:   gitlab/docker-compose.yml

$ git commit -m "Ajout du conteneur gitlab "
[master (root-commit) d5030d4] Ajout du conteneur gitlab
 1 file changed, 22 insertions(+)
  create mode 100644 gitlab/docker-compose.yml

```

* Ajout du serveur gitlab pour être en mesure de pousser notre configuration 

```bash
$ git remote add origin http://thomas@172.29.0.2/sysadmin/dockers.git

$ git push origin master
Password for 'http://thomas@172.29.0.2': 
Counting objects: 4, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (4/4), 642 bytes | 0 bytes/s, done.
Total 4 (delta 0), reused 0 (delta 0)
To http://172.29.0.2/sysadmin/dockers.git

```

* Résultat si nous retournons sur la page du projet , dans gitlab nous verrons nos fichiers 

![](./imgs/gitlab-14-view-projet-with-data.png)

* Le problème est que visuellement c'est pas très beau vous pouvez donc ajouter un __README__ afin d'avoir une description directement dans la visualisation du projet , un peu comme avec __github__ 

```bash
$ cat README.md
 # Description

 Ce projet à pour but de contenir les définitions des conteneurs , ceci est des conteneurs de développement !!

 # Problème connu

**AUCUN**

$ git add README.md
$ git commit -m "Ajout du fichier README "
$ git push origin
```

![](./imgs/gitlab-15-view-projet-with-README.png)

* Nous avons donc le projet sysadmin/dockers de complété , bien entendu il y aura de l'ajout de fichier mais l'idée général est en place , passons à un autre dépôt.


## Intégration dépôt local vers le serveur configuration du conteneur

L'idée général est de conserver notre __docker-compose et DockerFile__ de gitlab, cependant une fois en exécution, nos conteneurs on bien souvent des volumes de configurer et il nous arrive de modifier ces fichiers de configuration. L'idée du dépôt goishi-dockers est justement de répondre à cette situation . 

Si je reprend l'idée du conteneur gitlab 

```bash
$ cat gitlab/docker-compose.yml | grep etc
            - '/srv/docker/x3-gitlab-f/gitlab/etc:/etc/gitlab'
```

Je vais donc configurer le répertoire __/srv/docker__ afin qu'il soit ré visionné , c'est partie.

```bash
$ cd /srv/docker/
$ ls
coco-db-t  ossec  x3Apache  x3-gitlab  x3-gitlab-f  x3-jenkins

$ sudo git init .
Initialized empty Git repository in /srv/docker/.git/``
```

* Ajout du répertoire de configuration de __gitlab__ 

```bash
$ sudo git add x3-gitlab-f/gitlab/etc/
```

* Mais il y a plein de fichier qui sont présent dont je n'ai que peu d'intérêt donc je vais ignorer ces fichiers car ils ne sont que pour des testes et je ne veux pas qu'il soit pris en considération . Comme vous pouvez le voir pour le moment AUCUN commit ne fut réalisé vers le serveur, tous est local.

```bash
$ $ sudo git status
On branch master

Initial commit

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

   new file:   x3-gitlab-f/gitlab/etc/gitlab-secrets.json
   new file:   x3-gitlab-f/gitlab/etc/gitlab.rb
   new file:   x3-gitlab-f/gitlab/etc/ssh_host_ecdsa_key
   new file:   x3-gitlab-f/gitlab/etc/ssh_host_ecdsa_key.pub
   new file:   x3-gitlab-f/gitlab/etc/ssh_host_ed25519_key
   new file:   x3-gitlab-f/gitlab/etc/ssh_host_ed25519_key.pub
   new file:   x3-gitlab-f/gitlab/etc/ssh_host_rsa_key
   new file:   x3-gitlab-f/gitlab/etc/ssh_host_rsa_key.pub

Untracked files:
  (use "git add <file>..." to include in what will be committed)

  coco-db-t/
  ossec/
  x3-gitlab-f/gitlab/data/
  x3-gitlab-f/gitlab/logs/
  x3-gitlab/
  x3-jenkins/
  x3Apache/


$ sudo git status  | egrep -v "new file" | grep "/$" | tr -d "\t"
coco-db-t/
ossec/
x3-gitlab-f/gitlab/data/
x3-gitlab-f/gitlab/logs/
x3-gitlab/
x3-jenkins/
x3Apache/

$ sudo vim .gitignore

$ sudo git add .gitignore

$ sudo git commit -m "Ajout fichier de configuration de gitlab et gitignore"

```

* Tous comme la dernière fois on ajoute la configuration pour être en mesure de pousser la configuration et on pousse

```bash
$ sudo git remote add origin http://thomas@172.29.0.2/config/goishi-dockers.git
$ sudo git push origin master
Password for 'http://thomas@172.29.0.2': 
Counting objects: 14, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (12/12), done.
Writing objects: 100% (14/14), 25.89 KiB | 0 bytes/s, done.
Total 14 (delta 0), reused 0 (delta 0)
To http://172.29.0.2/config/goishi-dockers.git
 * [new branch]      master -> master

```

Résultat :

![](./imgs/gitlab-16-docker-volume-conf.png)

## Intégration dépôt configuration du serveur 

J'ai fait la création d'un dépot __config/goishi__ ce dépôt va me servir pour la configuration du serveur , en fait sous __config/NOM\_SERVER__ je conserve toujours le répertoire __/etc__ vielle habitude avant d'être sous docker :P , c'était critique pour conserver les applications localement définie.
Maintenant bien que moins critique ça me permet de conserver l'ensemble de l'information de la machine que la configuration soit local (liste des utilisateurs , configuration du système de gestion de la configuration (puppet), script d'initialisation ... ) 

Nous allons donc procéder avec la configuration .

```bash
$ cd /etc/
$ sudo git init .
Initialized empty Git repository in /etc/.git/
$ sudo git add *
$ sudo git commit -m "Ajout du répertoire etc pour goishi"

$ sudo git push origin master
Password for 'http://thomas@172.29.0.2': 
Counting objects: 1078, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (836/836), done.
Writing objects: 100% (1078/1078), 3.36 MiB | 3.45 MiB/s, done.
Total 1078 (delta 40), reused 0 (delta 0)
remote: Resolving deltas: 100% (40/40), done.
To http://172.29.0.2/config/goishi.git
 * [new branch]      master -> master
```

# Concept de l'organisation et présentation

Voici en gros le concept de l'organisation (la structure), ceci est une suggestion libre à vous de l'utiliser ou pas , mais j'aime bien ce mode de travail. Peu importe ce que je vous montre aujourd'hui dans 3 mois vous l'avez oublié si vous l'utilisez pas, puis honnêtement on s'en fou :p ,puis c'est correct ... Par contre les concepts on tendance à rester plus longtemps :P. 

![](./imgs/environnemnet-git.png)

* Les groupes :
    * __Sysadmin__ : est complètement indépendant des systèmes où il sont déployer , ceci est supposé être complètement réutilisable
    * __Config__ : Contient des fichiers propre à un système , voir un regroupement de système , voilà pourquoi j'indique le nom du système dans le nom du projet.

Nous allons vers dans quelques instants que bien que l'ensemble soit complètement séparer __gitlab__ nous permet de lier les différents projet afin d'avoir un tout cohérent. 

Afin de faire une démonstration de cette structure je vais faire une démonstration, ceci aura 2 avantages faire une présentation pratique de l'organisation que je vous propose et aussi de permettre de visualisé les fonctionnalités de __gitlab__.

## Ze Documentation !!

La Documentation , certain aime d'autre déteste , bon bien entendu je suis de la première catégorie , la documentation pour moi est très importante. 
Vous pourriez dire que : 

* C'est une perte de temps ...
* Que vous avez pas le temps ...
* Que c'est long ...

Effectivement, sur le moment le retour sur investissement (temps) n'est pas claire , mais personnellement il n'y a RIEN qui m'énerve plus que d'avoir rencontré un problème , le revivre et ne plus me souvenir de la solution trouvé originalement et reperdre 1 ou 2 heures (voir plus) pour remettre en place une solution . 

Puis en plus j'ai une petite tête, telle que mentionné plus tôt on oublie après 3 mois (parfois moins ) donc la solution que j'ai trouvé est de noté pour déchargé mon cerveau et faire de la place pour d'autre information plus pertinente sur le moment.

Dernier point sur l'aspect du temps , il y a plusieurs niveau de documentation , il y a la propre travaillé plusieurs fois que l'on peut donnée à tous le monde et il y a les notes brute. Les notes brutes ont l'avantage d'avoir beaucoup d'information et de remettre en avant les idées travaillés sur le moment . Il y a assurément des problèmes d'écriture , d'organisation , ... mais il y a néanmoins une trace des opérations réalisé. 

Tous ça pour dire que **gitlab** offre un wiki intégré :D.  Allé une petite démonstration :

Le lien pour le wiki est accessible depuis le projet dans la bar du haut :

![](./imgs/gitlab-17-lien-wiki.png)

La première page créer sera la page d'accueil du wiki :

![](./imgs/gitlab-18-home-page-wiki.png)

Voici un exemple de résultat 

![](./imgs/gitlab-19-home-page-wiki-data.png) 

Comme vous pouvez le voir ceci est du **wiki markdown** pour l'ensemble de la syntaxe vous avez l'aide disponible en bas de la page , nous y reviendrons un peu pour mettre en lumière certaines fonctionnalité intéressante, mais je vous laisse explorer les possibilités.

### Ze Documentation off-line

Nous parlons de git , et de gestion de révision , ce qui est fabuleux avec __gitlab__ est que le wiki est lui même un dépôt GIT !! Magnifique !!
Si vous allez sur le wiki et que vous regardé en haut à droite vous aurez le lien **Clone repository** .

En cliquant dessus vous aurez les instructions afin d'être en mesure de récupérer le dépôt git pour la doc.

Voici une démonstration :

```bash
$ mkdir -p ~/gitlab-demo/wikis/config
$ cd ~/gitlab-demo/wikis/config
$ git clone http://thomas@git.training.x3rus.com/config/goishi.wiki.git && cd goishi.wiki/
$ ls
home.md
$ cat home.md 
 # Goishi 

Wiki pour la gestion de la machine goishi laptop de travail (**machine a écrire**) dans le train 

 # description

* Préparation de formation
* Analyse pour les prochaines taches sur le serveur ...
``` 

Nous pouvons donc modifier la documentation directement avec votre éditeur préféré ( aka VIM :P ) réalisons une petite modification afin de voir le comportement . Je vais modifier la première section . 

```bash
$ vim home.md

$ cat home.md
 # Goishi 

Wiki pour la gestion de la machine goishi laptop de travail (**machine a écrire**) dans le train 

Ce wiki contiendra l ensemble de la documentation des notes brutes ...

 # description

* Préparation de formation
* Analyse pour les prochaines taches sur le serveur ...
```

Je commit le changement dans le dépôt local et pousse le tout sur le serveur

```bash
$ git commit -a -m "Ajout d information sur la page principale"
[master 526a85e] Ajout d information sur la page principale
 1 file changed, 3 insertions(+), 1 deletion(-)

$ git push origin master
Password for 'http://thomas@git.training.x3rus.com': 
Counting objects: 3, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 368 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
To http://git.training.x3rus.com/config/goishi.wiki.git
   ea90534..526a85e  master -> master

```

Résultat :

![](./imgs/gitlab-20-home-page-wiki-modifier.png)

Je vois déjà les levés de bouclier contre cette solution mentionnant que les gens préfère avoir l'interface pour faire la gestion que c'est plus simple qu'un éditeur texte performant ... Je comprend , du moins j'essaye :P ... Pour vous il y a la solution d'installer **gollum**  

```bash
$ gem install gollum github-markdown
$ gollum
 == Sinatra/1.3.5 has taken the stage on 4567 for development with backup from Thin
 >> Thin web server (v1.5.0 codename Knife)
 >> Maximum connections set to 1024
 >> Listening on 0.0.0.0:4567, CTRL+C to stop
```

En allant à l'URL [http://127.0.0.1:4567](http://127.0.0.1:4567), vous aurez toute la non convivialité de l'interface web :P.

TODO : ajouter des copie d'écrans de **gollum**.

![](./imgs/gitlab-22-gollum.png)

## La billetterie 

Nous avons donc :

* La conservation des fichiers ( configuration, définition de conteneur, scripts , ...) l'ensemble de manière révisionné avec GIT 
* La documentation en ligne et off line , l'ensemble AUSSI révisionné avec git 

En plus de tous ça __gitlab__ nous offres un système de billetterie , oui vous pouvez le dire la vie est BELLE !! :D. 
Chaque projet a son système de billets :

![](./imgs/gitlab-21-issues-home.png)

Organisation du système :

* 1 billet ou issue en anglais représente l'équivalent d'une tache
* Vous avez la possibilité surtout si vous réalisez du travail collaboratif avec d'autre personne d'utiliser le **board** intégré directement au système 
* La mise en place de **label** ou étiquette en français pour dans le future ressortir l'ensemble des billets ayant l'étiquette 
* Les Milestones qui sont un regroupement de tâches ou issue .

Afin de réaliser la présentation nous allons voir un cas concret ceci nous permettra de voir ma méthode de travail aussi :D .

### Description du cas pour la présentation 

Nous avons mis en place le conteneur **gitlab** et nous prévoyons mettre beaucoup de choses dedans , ceci est notre base de savoir ... Mais , mais on a pas couvert la question des sauvegardes du serveur gitlab :P. Nous allons donc modifier notre configuration afin d'ajouter le système de sauvegarde périodique du gitlab .

Encore un fois j'en profite pour montrer mon mode de fonctionnement, donc à ne pas prendre cash. 

Rapidement si je veux ajouter le système de sauvegarde je risque fort probablement de modifier  

* le conteneur **gitlab** , donc le projet **sysadmin/dockers** qui contient la définition de mon conteneur
* La configuration du conteneur **gitlab** contenu dans le projet : **goishi-dockers** 

Comme chaque projet a son système de billetterie où définir mon billet ?? Pour le moment nous n'avons pas beaucoup de projet, mais ceci peut devenir complexe. Prenons un moment de recule comment mon cerveau fonctionne , lors que je me dit je veux faire ceci ou j'ai déjà fait cela ? Généralement ce qui survient dans mon esprit à oui je l'avais mis en place à la maison, ou sur mon serveur ... comment je l'avais fait. 
Donc j'ai opté pour utiliser le projet **config/Nom-Machine** pour contenir l'ensemble des tâches , car ceci m'assure d'avoir le contexte. 

Bon , qu'est-ce que j'entends des personnes qui disent, oui mais moi j'ai des tâches qui touches plusieurs machines. Moi aussi dans un autre contexte j'ai aussi des tâches qui touches plusieurs machinent quand j'assiste un ami pour son environnement. Vous pourriez donc créer un projet **config/datacenter** pour ce type de tâches ou n'importe quelle regroupement qui vous parle. 

Pour ceux, car je vous entends, qui pensent c'est pas super car le billet est dans un projet, mais tu fais des modifications dans un autre ... oui pour ça la réponse arrive :D. 

Donc réalisons la création du billet dans le projet **config/goishi** car le système de gitlab est sur cette machine

### Création du billet 

Je vais donc faire la création du billet , je vais donc dans le projet sous l'onglet **issue** et fait __new__ :D (woww vous aviez besoin d'une documentation  pour ça :P ).

![](./imgs/gitlab-23-creations-issue.png)

Je vous invite fortement à utiliser les étiquettes (__label__) pour l'avenir afin d'avoir un regroupement des billets , ceci pourra facilité vos recherches surtout quand vous savez pas trop ce que vous cherchez. Ceci vous permettra aussi de voir l'ensemble des billets pour un service .

Personnellement je définie des étiquettes pour :

* Le nom du service, par exemple : __gitlab__, __proxy__, __jenkins__, ...
* Le type de du billet : Tâche, incident ( ceci me permet de lister facilement les incidents non planifier survenu :) )
* Occasionnellement pour des cas spécifique le rôle : sauvegarde , monitoring , ceci me permet par exemple d'identifier les opérations de **sauvegarde** pour plusieurs service telle que __gitlab__, service de courriel,... 

Bien entendu ça sert à rien de faire 90 étiquettes si vous ne les utilisez pas :P , bien entendu il est possible d'assigner des étiquettes en masse pour ajouter une nouvelle étiquette que nous avions pas dans le passé. 

Voici donc le résultat des étiquettes pour notre cas :

![](./imgs/gitlab-25-label-resultat.png) 

### Visualisation du billet et commandes

Voici le résultat du billet créé comme vous pouvez le voir sur le menu de droite il y a beaucoup d'information sur l'état du billet :

![](./imgs/gitlab-26-show-issue.png)

Il existe énormément de commande sous gitlab pour réaliser des opérations je vous invite à consulter la page de documentation  : [slash commands](https://gitlab.com/help/user/project/slash_commands)

Voici quelques commandes disponible et intéressante :

* **Définition du temps estimé** 
    Si vous pensez prendre 1 jours pour réalisé l'opération ou quelques heures vous pouvez le définie comme ceci :
    ```
    /estimate 8h
    /estimate 4j
    ```

* **Ajout du temps passé sur un billet**
    Une fois un temps x de passé sur le billet 
    ```
    /spend 30m
    /spend 3h
    ```

* **Identifier que la tache est en cours**
    ```
    /wip
    ```

Voici une copie d'écran de l'ajout :

![](./imgs/gitlab-27-add-comment-with-slashs-cmd.png)


### Utilisation du tableau

Personnellement je l'utilise très peu , car je suis majoritairement seule sur les tâches et que je n'ouvre pas 60 billets que je conserve ouvert en backlog pour un jour travailler dessus . Je suis plutôt du genre je veux faire telle opération et je n'ouvre pas d'autre billet tant que la "tâche" en cours n'est pas terminé. Ce fut pas toujours le cas :P , mais j'ai constaté que sinon je ne terminais  pas les tâches ... 

Mais prenons quelques minutes pour visualiser la fonctionnalité puis vous en ferez ce que vous voulez :D.

Pour information le __board__ utilise les labels pour être en mesure de catégoriser les billets et les mettre dans la bonne colonne , donc l'ensemble des étiquettes peuvent être utilisées .
Voici le tableau nu :D.

![](./imgs/gitlab-28-fresh-board.png)

Nous allons ajouter les étiquettes suggérées : **To Do** et **Doing**, en cliquant sur **Add defaults lists** .

En cliquant sur **Add list** vous pourrez ajouter VOS label , il est possible de glisser un billet d'une colonne à l'autre automatiquement Gitlab réalisation l'ajout et la suppression des étiquettes associé.


### Création d'un milestone pour regrouper des tâches

La création de __milestone__ j'en fait régulièrement, mais toujours après coup :P . Généralement le processus est le suivant je crée un billet puis je pense que en 2  heures ce sera corrigé. Puis mon cerveau ce met en marche tranquillement , style diesel, puis je me dit réalisons ceci en plus , puis à oui j'avais pas pensé à cela , etc . Je suis sur que vous connaissez aussi cette situation , résultat quand j'ai 3 idées / billet qui se sont créés je réalise la création du milestone pour regrouper l'ensemble :D. 

Voici un exemple de création de milestone 

![](./imgs/gitlab-29-creation-milestone.png)

Et maintenant le résultat avec un billet dedans :D 

![](./imgs/gitlab-30-milestone-avec-billet.png)


## Réalisation d'un billet 

Bon maintenant on passe à la méthode de travail pour attendre la résolution de ce billet , quelle sont les critères de succès  ? :

1. Un travail qui fonctionne 
2. Une documentation complète , pas obligatoirement formaté mais qui relate le travail réalisé 
3. La conservation des fichiers de configuration 
4. Un billet contenant de l'information 

En gros c'est pas mal les objectifs que nous devons attendre , on est tous d'accord pour dire que le point 1 sera réalisé , pour le reste ... **ishh** généralement c'est compliqué :D . Mais pas pour moi, car mon mode de travail fait en sorte que je l'information sera présent. 

### Démarrage de la documentation :D 

Laissé moi deviné quand vous travaillez souvent vous ouvrez un éditeur puis parfois vous collez des informations dedans , ceci de manière temporaire que ce soit un __hostname__ , un port , un lien de documentation , un bout de logs , ... 

Pour commencez ARRÊTER ça tous de suite , ou alors sauvegardez ce putain de fichier qui vaut de l'or parfois , mais trop souvent effacé car complètement incomplet donc difficilement compréhensible plus tard. 

Nous allons utiliser le système du wiki pour conserver l'ensemble de l'information , pour cela nous allons extraire le dépôt git .

```bash
$ cd ~/gitlab-demo/wikis/config/goishi.wiki
$ ls 
home.md

$ mkdir -p ~/gitlab-demo/wikis/config/goishi.wiki/Issues/Taches/1-Mise-en-place-backup-gitlab
$ cd ~/gitlab-demo/wikis/config/goishi.wiki/Issues/Taches/1-Mise-en-place-backup-gitlab
$ vim note-raw.md
```

Le fichier **note-raw.md** contiendra l'ensemble des opérations pour la réalisation de la tâches , ceci peut être un gros , un petit fichier ... 

Voici un exemple du contenu initiale 

```bash
$ cat note-raw.md
 # Description 
  
 Mise en place d une strategie de backup pour gitlab
    
 L installation original de gitlab n inclut pas la sauvegarde ... important de le mettre en place . 
      
 Billet : config/goishi#1 
        
 # Opérations 
```

Comme vous pouvez le devinez l'ensemble des donnes seront dans la section Opération  !!

Je vais aussi définir cette page dans la page d'accueil , en fait moi j'ai une sous section dans mon cas ... Mais le concept reste le même, je vais donc modifier le fichier home.md à la racine du wiki.

```bash
$ cd ~/gitlab-demo/wikis/config/goishi.wiki/
$ vim home.md
$ cat home.md
 # Goishi 

Wiki pour la gestion de la machine goishi laptop de travail (**machine a écrire**) dans le train 

Ce wiki contiendra l ensemble de la documentation des notes brutes ...

 # description

* Préparation de formation
* Analyse pour les prochaines taches sur le serveur ...

 # Tâches

* 04-Jul-17 : [Mise en place du backup de gitlab](./Issues/Taches/1-Mise-en-place-backup-gitlab/note-raw) , billet config/goishi#1 
```

Je commit la nouvelle page du wiki et pousse l'ensemble vers le serveur .

```bash
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

    modified:   home.md

  Untracked files:
  (use "git add <file>..." to include in what will be committed)

    Issues/

  no changes added to commit (use "git add" and/or "git commit -a")

$ git add Issues 
$ git commit -a -m "Ajout documentation billet config/goishi#1" 

$ git push origin master
Password for 'http://thomas@git.training.x3rus.com': 
Counting objects: 7, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (5/5), done.
Writing objects: 100% (7/7), 785 bytes | 0 bytes/s, done.
Total 7 (delta 1), reused 0 (delta 0)
To http://git.training.x3rus.com/config/goishi.wiki.git
   526a85e..2949c4f  master -> master
```

Si nous allons sur le wiki l'ensemble de l'information est maintenant présent avec le lien , autre opération que je réalise est de lié le billet avec le wiki .
Je vais donc sur le billet et édite la description initiale pour ajouter le lien wiki .

![](./imgs/gitlab-31-link-issue-wiki.png)

Ici c'est le problème le système **git** pour le wiki n'est pas lié avec le billet par défaut :-/. 

Voilà MAINTENANT nous sommes prêt à travailler sur le problème , oui c'est plus long, mais je considère que ceci est un gros gain dans le future...

Voilà le mode de fonctionnement :

* 1 terminal : avec le fichier wiki de la documentation wiki ouvert
* n terminal : pour les opérations 

Je note au fur et à mesure les opérations , voici un exemple de la réalisation de la documentation pour le billet sur la mise en place du backup :

[note-raw billet de backup](./note-raw-billet.md)

Ce qui est manifique est l'intégration , une fois la documentation réalisé je commit le changement dans le wiki :

```bash
$ cd ~/gitlab-demo/wikis/config/goishi.wiki/Issues/Taches/1-Mise-en-place-backup-gitlab
$ git status 
$ # si requis ajout de fichier git add
$ git commit -a -m "Documentation backup de gitlab config/goishi#1 "
$ git push origin master
```

* Lors de la réalisation de la configuration du backup nous avons aussi modifier un fichier dans le projet **sysadmin/dockers** , le fichier de définition __docker-compose.yml__ 

* Nous allons aussi commiter ce fichier , ce changement est réellement en corrélation avec le billet de mise en place du backup nous allons donc lié le commit avec le billet

```bash
$ cd ~/gitlab-demo/sysadmin/dockers
$ git status 
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

    modified:   gitlab/docker-compose.yml

$ git add gitlab/docker-compose.yml
$ git commit -m "config/goishi#1 définition des variables dans le conteneur pour activer le backup "

```

C'est la que la magie est super car si nous retournons dans le billet nous pourrons voir le commit présent le billet , dernière entré : 

![](./imgs/gitlab-32-commit-dans-billet.png)

Si nous cliquons sur le lien du commit nous aurons le contenu :

![](./imgs/gitlab-33-visualisation-du-commit.png)

Prendre note que le lien sysadmin/dockers@c8de2e10 peut aussi être écrit dans le wiki et il fera le lien , je l'utilise parfois surtout quand je suis en mode exploratoire pour identifier un point précis dans la recherche de la solution , exemple , à ce moment ça fonctionne .

Voilà l'idée général 

## La recherche

Car c'est bien beau mettre toute cette information mais si on ne le retrouve pas il n'y a pas d'intérêt , donc en haut à droite vous avez la boite de recherche. Ce qui est super est qu'il va chercher dans l'ensemble : __issue__, __wiki__, __commit__ ...

Voici un exemple si nous cherchons **gitlab** 

![](./imgs/gitlab-34-search-gitlab.png)

Et en PLUS !! Car bon , j'ai rien contre mon navigateur web mais je peux faire un gros **GREP** sur mes dépôts locaux :D

## Utilisation des branches

L'utilisation des branches dans GIT et des __merges request__ dans le cas présent je n'ai pas couvert la question des branches et __merge request__ de la branche vers la branche __master__ . Je ne l'utilise que très très rarement de le contexte de l'administration de systèmes , nous verrons probablement cette utilisation quand nous parlerons de l'intégration de __gitlab__ avec __jenkins__ . 

Pourquoi je n'utilise pas les branches ? 

* Car je suis vieux et que j'ai utilisé trop souvent __subversion__, __CVS__ et autre qui n'ont pas le concept de branche :P 
* Car je suis tous seul sur les machines ou un nombre très restreint donc nous nous marchons pas sur les pieds 
* Car le serveur a une configuration active , mettre un branche pour représenté quelque chose qui est déjà actif n'est pas pertinent .

Quand j'utilise les branches alors ?

* Quand je développe un groupe de script et que je veux avoir un état en cours de développement sans cassé ce qui fonctionne 
* Quand je veux rajouter une fonctionnalité sur une application et un script 


# Présentation de cas concret 

Bon j'en convient que c'est un mode de travail , qui est contraignant , si certain croit que c'est purement inutile , pas de problème :D , vous pourrez faire 20 fois les mêmes opérations à moins que votre mémoire vous permette de mémorisé tous , Bonne chance.

Pour ceux qui se demande , est-ce qu'il fait vraiment ça , j'aimerai bien , mais honnêtement sur un petit exemple je le visualise bien mais ... mais ... mais ... 

Faut être honnête :

* J'ouvre PAS un billet pour changer un mot de PASSE !!
* Parfois j'oublie moi aussi surtout quand ça déboule à toute vitesse, mais comme j'utilise toujours la méthode de conservation dans un fichier vim mes opérations , ceci me permet de créer le billet plus tard .
* Gardez aussi en tête ceci est pour conservé des notes BRUTE ... Est-ce que je peux le fournir à mon collègue ?!?! Peut-être selon la personne , est-ce une bonne base pour rédiger un procédure claire certainement mais il y a du travail.

Voici quelque exemple de billet pour la présentation vidéo , vous n'aurez PAS accès à mon gitlab :P.

* https://git.x3rus.com/goke/config/issues/10 : le même billet
* https://git.x3rus.com/goke/config/issues/40 : Création du conteneur pour ansible utilisé dans le cadre d'AWS , avec lien billet de test d'ansible.
* https://git.x3rus.com/goke/config/milestones/2 : Mise en place du docker registry privé
