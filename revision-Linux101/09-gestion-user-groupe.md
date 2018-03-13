# Gestion des utilisateurs et groupes

## Définition de l'utilisateur

l semble un peu bizarre de parler de définition d'utilisateur alors que nous savons ce qu'est un utilisateur d'un ordinateur, nous parlerons des caractéristiques d'un utilisateur sous GNU/Linux. Nous verrons qu'il y a deux type d'utilisateur: de service et interactif. Voyons pour commencer ce qu'est un utilisateur que ce soit un utilisateur de service ou interactif .

Un utilisateur à :

* **Obligatoirement** :
	* Un **nom** : Ce nom d'utilisateur sera utiliser pour établir une connexion par exemple et sera présenté sous ce nom au autre utilisateur incluant l'administrateur.
    * Un **UID** (l'identifiant numérique de l'utilisateur) : Ce numéro UNIQUE à l'utilisateur sera utilisé par le système pour représenter l'utilisateur.
    * Un **GID** (l'identifiant numérique du groupe de l'utilisateur) : Ce numéro représente le groupe primaire auquel l'utilisateur est associé, chaque utilisateur doit avoir un groupe primaire au moins. Lors de la création d'un nouveau fichier ce dernier aura comme propriétaire le UID et comme groupe propriétaire , le groupe primaire.
    * Un **HomeDirectory** (le répertoire personnel de l'utilisateur): Ce répertoire personnel habituellement définie dans le répertoire /home permet à l'utilisateur de stocker ses fichiers.
    * Un **Shell** (l'interpréteur de commandes): L'interpréteur de commande shell est utilisé lors de la connexion de l'utilisateur. Telle que vu lors de la session Linux 101 , il est possible d'avoir plusieurs type d'interpréteur de commande telle que zsh, tksh, csh, ... Nous allons voir aussi d'autre type d'interpréteur de commande telle que /bin/false , /usr/sbin/nologin , ...
* Optionnel:
    * Un **commentaire** : Un champs commentaire est utilisateur pour offrir de l'information sur l'utilisateur telle que son vraie nom , ou autre information.
    * Des **groupes secondaire** : Il est possible d'assigner d'autres groupes à l'utilisateur afin de lui attribuer des droits.
    * Un **mot de passe** : L'assignation de mot de passe est possible mais PAS obligatoire. 

### Utilisateur de service (system accounts) et Utilisateur interactif ou régulier

Nous allons voir la différence entre ces deux type d'utilisateur bien qu'il est l'ensemble des propriétés définie plus haut lors différence principalement est dans leur fonction.

* **Utilisateur interactif ou régulier** : cette utilisateur est l'utilisateur classique qui réalisera une connexion au système avec une interaction avec la machine , il établira une connexion par un service que ce soit SSH, un service de partage de fichiers, ou tous autre service. Le système lui demandera utilisera un mode d'authentification communément une demande de mot de passe. 
* **Utilisateur de service** : cette utilisateur est utilisé pour rouler un service, si nous prenons le cas du service ssh serveur (openSSH) lorsque le logiciel est démarrer ce n'est pas l'utilisateur root qui le roule mais un utilisateur qui à moins de droit, ceci limite les accès que le processus  a . De plus s'il y a un problème avec le logiciel, une faille de sécurité l'attaquant ne pourra utiliser que les accès que le service possède , il ne sera donc pas administrateur sur le système. Une des particularités de ce type utilisateur est qu'il ne possède pas de mot de passe, ceci n'est pas obligatoire car il n'y a pas d'authentification qui n'est réalisé. De plus l'interpréteur de commande (shell) est souvent  un interpréteur non utilisable en cas de connexion, nous retrouvons donc des interpréteurs telle que : /bin/false , /usr/sbin/nologin .

En plus d'être identifiable par le manque de mot de passe et par leur interpréteur de commande (shell) particulier , ils ont bien souvent un UID numéro d'identification particulier. Comme bien souvent il y a un différence entre la distribution Ubuntu / Debian et RedHat.

* Ubuntu / Debian :
	* Utilisateur de service : UID <= 999
    * Utilisateur interactif ou régulier : UID >= 1000
* RedHat :
    * Utilisateur de service : UID <= 499
    * Utilisateur interactif ou régulier : UID >= 500

```
Mais ceci n'est qu'une convention que je vous invite a respecté pour vous faciliter la vie , et faciliter la vie de vos collègues , malheureusement aucune garantie n'est fournit et parfois vous trouverez des organisations qui ont des utilisateurs de service et interactif mélangé
```

### Visualisation des utilisateurs

Avant de commencer à créer et supprimer des utilisateurs voyons les utilisateurs présent sur le système, ceci nous permettra par la suite de mieux créer nos utilisateurs car nous aurons une connaissance de ceux présent , de plus nous pourrons valider efficacement que nos nouveaux utilisateurs sont bien créer.

Commençons par visualiser notre utilisateur , vous pouvez utiliser la commande id qui vous affiche l'information sur votre utilisateur, vous aurez le nom de l'utilisateur sont **UID**, son groupe primaire **GID**, ainsi que les groupes secondaire avec leur numéro . Il est aussi possible de fournir en argument à la commande id le nom d'un autre utilisateur:

```bash
 # Visualisation de l'ID sans argument
admuser@srv01:~$ id
uid=1000(admuser) gid=1000(admuser) groups=1000(admuser),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),111(lpadmin),112(sambashare)
 
 # Visualisation de l'ID avec argument 
admuser@srv01:~$ id sshd
uid=105(sshd) gid=65534(nogroup) groups=65534(nogroup)
```

Ceci est bien, cependant pour avoir l'information sur l'utilisateur, il nous faut connaitre le nom de ce dernier de plus avec la commande id nous n'avons pas l'information sur le **shell**, le répertoire personnel (**homedirectory**). Le répertoire /etc/ contient un fichier qui peut fournir l'ensemble de l'information ce dernier est **/etc/passwd**. Voici un exemple du fichier :

```bash
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/bin/sh
bin:x:2:2:bin:/bin:/bin/sh
sys:x:3:3:sys:/dev:/bin/sh
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/bin/sh
man:x:6:12:man:/var/cache/man:/bin/sh
lp:x:7:7:lp:/var/spool/lpd:/bin/sh
mail:x:8:8:mail:/var/mail:/bin/sh
news:x:9:9:news:/var/spool/news:/bin/sh
uucp:x:10:10:uucp:/var/spool/uucp:/bin/sh
proxy:x:13:13:proxy:/bin:/bin/sh
www-data:x:33:33:www-data:/var/www:/bin/sh
backup:x:34:34:backup:/var/backups:/bin/sh
list:x:38:38:Mailing List Manager:/var/list:/bin/sh
irc:x:39:39:ircd:/var/run/ircd:/bin/sh
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/bin/sh
nobody:x:65534:65534:nobody:/nonexistent:/bin/sh
libuuid:x:100:101::/var/lib/libuuid:/bin/sh
syslog:x:101:103::/home/syslog:/bin/false
messagebus:x:102:105::/var/run/dbus:/bin/false
whoopsie:x:103:106::/nonexistent:/bin/false
landscape:x:104:109::/var/lib/landscape:/bin/false
sshd:x:105:65534::/var/run/sshd:/usr/sbin/nologin
admuser:x:1000:1000:admuser,,,:/home/admuser:/bin/bash
```

Comme vous pouvez le constater ceci comprend l'ensemble des informations mentionné au début ,  si vous regardez les permissions du fichier il est lisible par tout le monde, ceci est obligatoire. Dans l'atelier suivant vous aurez l'occasion de voir ce qui se produit si nous changeons les permissions sur ce fichier.

Il existe aussi une autre méthode pour extraire l'information des utilisateurs non pas en utilisant le fichier **/etc/passwd** mais en utilisant la commande **getent**. Voici le résultat de la commande

```bash
 # extration des utilisateurs avec getent
admuser@srv01:~$ getent passwd
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/bin/sh
bin:x:2:2:bin:/bin:/bin/sh
sys:x:3:3:sys:/dev:/bin/sh
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/bin/sh
man:x:6:12:man:/var/cache/man:/bin/sh
lp:x:7:7:lp:/var/spool/lpd:/bin/sh
mail:x:8:8:mail:/var/mail:/bin/sh
news:x:9:9:news:/var/spool/news:/bin/sh
uucp:x:10:10:uucp:/var/spool/uucp:/bin/sh
proxy:x:13:13:proxy:/bin:/bin/sh
www-data:x:33:33:www-data:/var/www:/bin/sh
backup:x:34:34:backup:/var/backups:/bin/sh
list:x:38:38:Mailing List Manager:/var/list:/bin/sh
irc:x:39:39:ircd:/var/run/ircd:/bin/sh
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/bin/sh
nobody:x:65534:65534:nobody:/nonexistent:/bin/sh
libuuid:x:100:101::/var/lib/libuuid:/bin/sh
syslog:x:101:103::/home/syslog:/bin/false
messagebus:x:102:105::/var/run/dbus:/bin/false
whoopsie:x:103:106::/nonexistent:/bin/false
landscape:x:104:109::/var/lib/landscape:/bin/false
sshd:x:105:65534::/var/run/sshd:/usr/sbin/nologin
admuser:x:1000:1000:admuser,,,:/home/admuser:/bin/bash
```

Dans notre système actuelle vous voyez exactement les même informations que le fichier **/etc/passwd** , cependant l'avantage de la commande **getent passwd** comparativement à la visualisation du fichier est que **getent** fournit l'ensemble des utilisateurs réellement disponible sur le système. Si votre serveur va chercher l'information dans un serveur **LDAP** telle que **Active Directory , OpenLdap** , ... Les utilisateurs disponible seront affiché !! 

**getent passwd** peut aussi prendre en argument un utilisateur ceci retournera donc uniquement l'information de l'utilisateur demandé.

## Définition du groupe

Après avoir vu l'utilisateur voyons les groupes ceci nous permettra de manipuler les utilisateurs et les groupes en même temps pour la suite de la leçon. Tous comme pour les utilisateurs nous retrouvons des **groupes de service** et des **groupes réguliers**.

Un groupe à :

* Obligatoirement:
	* Un **nom** : Ce nom sera utilisé principalement par les utilisateurs pour référencer ce groupe.
    * Un **GID** :  Le numéro d'identification du groupe , ce numéro est unique
* Optionnel :
    * Des **utilisateurs membres** : un groupe peut n'avoir aucun membrtilisateur de service (system accounts) et Utilisateur interactif ou régulier


### Groupe de service et Groupe régulier

Le concept est le même que pour les utilisateurs nous avons des groupes avec des numéros qui identifie leur type. Cependant ceci à le même problème que pour les utilisateurs c'est à dire que ceci est une convention donc rien ne garantie que le groupe du bon type uniquement à cause du numéro. Je le répète , cependant respecté le standard ne soyez pas l'administrateur qui n'a pas respecté cette convention.

* Ubuntu / Debian :
	* Groupe de service : GID <= 999
    * Groupe régulier : GID >= 1000
* RedHat :
	* Groupe de service : GID <= 499
    * Groupe régulier : GID >= 500

### Visualisation des groupes

Avant de commencer à créer et supprimer des groupe voyons les groupes présent sur le système, ceci nous permettra par la suite de mieux créer nos groupe car nous aurons une connaissance de ceux présent , de plus nous pourrons valider efficacement que nos nouveaux groupes sont bien créer.

Commençons par visualiser les groupes auquel j'appartiens, vous pouvez utiliser la commande id pour afficher l'information sur votre utilisateur et ainsi voir les groupe. Nous avons vu la commande id précédemment.

Le fichier **/etc/group** contient l'ensemble des groupes présent localement définie sur le système , voici un exemple de contenu

```bash
root:x:0:
daemon:x:1:
bin:x:2:
sys:x:3:
adm:x:4:admuser
tty:x:5:
disk:x:6:
lp:x:7:
mail:x:8:
news:x:9:
uucp:x:10:
man:x:12:
proxy:x:13:
kmem:x:15:
dialout:x:20:
fax:x:21:
voice:x:22:
cdrom:x:24:admuser
floppy:x:25:
tape:x:26:
[[ OUTPUT COUPÉ ]] 
```

Nous retrouvons aussi la commande **getent** qui peut être utilisé, mais cette fois ci avec l'argument **group**. Tout comme pour la commande **getent passwd**, avec la commande **getent group**  nous aurons en plus des groupes localement définie les groupes présent depuis une source externe telle que **Ldap** , ... Bien entendu dans notre cas ceci est équivalent 

```bash
admuser@srv01:~$ getent group | head -20
root:x:0:
daemon:x:1:
bin:x:2:
sys:x:3:
adm:x:4:admuser
tty:x:5:
disk:x:6:
lp:x:7:
mail:x:8:
news:x:9:
uucp:x:10:
man:x:12:
proxy:x:13:
kmem:x:15:
dialout:x:20:
fax:x:21:
voice:x:22:
cdrom:x:24:admuser
floppy:x:25:
tape:x:26:
```


## Création Utilisateur

Débutons par la création d'un utilisateur , gardons en tête les 2 types d'utilisateurs (service et régulier). La commande original est **useradd** cette dernière à l'avantage d'être disponible sur l'ensemble des systèmes. Quand elle est invoquée sans l'option -D, la commande **useradd** crée un nouveau compte utilisateur qui utilise les valeurs indiquées sur la ligne de commande et les valeurs par défaut du système. En fonction des options de la ligne de commande, la commande **useradd** fera la mise à jour des fichiers du système, elle pourra créer le répertoire personnel et copier les fichiers initiaux. Cette commande créer aussi un groupe avec le même nom que l'utilisateur et ce groupe sera la groupe primaire de l'utilisateur. Voici un exemple d'utilisation de la commande avec le résultat suite à la création  :

```bash
 # création de l'utilisateur
admuser@srv01:~$ sudo useradd thomas
 
 # Visualisation de ce dernier
admuser@srv01:~$ id thomas
uid=1001(thomas) gid=1001(thomas) groups=1001(thomas)
admuser@srv01:~$ getent passwd thomas
thomas:x:1001:1001::/home/thomas:/bin/sh
admuser@srv01:~$ ls /home/thomas
ls: cannot access /home/thomas: No such file or directory
```

Comme vous pouvez le constater l'utilisateur __thomas__ fut créé comme utilisateur régulier le système à donc pris le **UID** suivant disponible , étant sous Ubuntu ce dernier est 1001 car j'ai déjà l'utilisateur **admuser** avec le **UID** 1000. Un groupe fut automatiquement créé avec le nom de l'utilisateur ce dernier aussi est un groupe régulier car le **GID** est plus grand que 1000. L'utilisateur à un **shell** **/bin/sh** et son répertoire personnel (__home directory__) est **/home/thomas**, par contre la commande n'a PAS créé ce répertoire, nous pouvons le constater à la ligne 9. Dernier point l'utilisateur n'a pas de mot de passe d'associé.

Le fichier de configuration pour la commande **useradd** est **/etc/default/useradd** , de plus l'ensemble des paramètre disponible à la commande sont comme toujours disponible dans le man page : man **useradd**

### Commande adduser

Telle que mentionné **useradd** est la commande original RedHat et Ubuntu / Debian offre une interface plus "conviviale", le nom de la commande est **adduser**, en arrière cette commande utilise tous de même **useradd**. Tout comme avec la commande **useradd** , **adduser** choisira le premier identifiant (**UID**) dans le domaine défini pour les utilisateurs normaux dans le fichier de configuration.  L'**UID**  peut  être  forcé  avec  l'option --**uid**.

La commande utilise le fichier de configuration : **/etc/adduser.conf**, si vous avez ouvert le fichier de configuration précédent pour **useradd** vous constaterez qu'il y a beaucoup plus d'information dans celui de **adduser**.

Par défaut, chaque utilisateur d'un système Debian GNU/Linux se voit attribuer un groupe avec son propre nom. Les groupes d'utilisateurs facilitent la gestion des répertoires qui sont accessibles en écriture pour un groupe : les utilisateurs appropriés sont placés dans le nouveau groupe, le bit **SGID** du répertoire est positionné, et on s'assure que tous les utilisateurs ont un masque de création de fichiers (« **umask** ») de 002. Si cette option est désactivée en configurant **USERGROUPS** à no, tous les identifiants de groupe des utilisateurs seront **USERS\_GID**. Le groupe primaire des utilisateurs peut aussi être forcé en ligne de commande avec l'option __--gid ou --ingroup__ respectivement pour l'identifiant numérique et le nom du groupe. De plus, les utilisateurs peuvent être ajoutés à un ou des groupes définis dans **adduser.conf**, soit en positionnant ADD\_EXTRA\_GROUPS à 1
dans **adduser.conf**, soit en utilisant l'option __--add\_extra\_groups__ en ligne de commande.

Si  le  fichier  **/usr/local/sbin/adduser.local**  existe,  il est exécuté une fois que l'utilisateur a été configuré, de façon à réaliser des opérations propres au système. Les paramètres passés à **adduser.local** sont :
       nom\_utilisateur uid gid répertoire\_personnel

Démonstration:

```bash
 # Création
admuser@srv01:~$ sudo adduser thom
Adding user `thom' ...
Adding new group `thom' (1002) ...
Adding new user `thom' (1002) with group `thom' ...
Creating home directory `/home/thom' ...
Copying files from `/etc/skel' ...
Enter new UNIX password: 
Retype new UNIX password: 
passwd: password updated successfully
Changing the user information for thom
Enter the new value, or press ENTER for the default
	Full Name []: Thom
	Room Number []: 
	Work Phone []: 
	Home Phone []: 
	Other []: demo adduser
Is the information correct? [Y/n] y
 
 # Visualisation 
admuser@srv01:~$ id thom
uid=1002(thom) gid=1002(thom) groups=1002(thom)
admuser@srv01:~$ getent passwd thom
thom:x:1002:1002:Thom,,,,demo adduser:/home/thom:/bin/bash
admuser@srv01:~$ ls -la /home/thom/
total 20
drwxr-xr-x 2 thom thom 4096 Apr  9 13:05 .
drwxr-xr-x 5 root root 4096 Apr  9 13:05 ..
-rw-r--r-- 1 thom thom  220 Apr  9 13:05 .bash_logout
-rw-r--r-- 1 thom thom 3486 Apr  9 13:05 .bashrc
-rw-r--r-- 1 thom thom  675 Apr  9 13:05 .profile
```

L'utilisateur __thom__ est à présent créé,  comme vous pouvez le constater **adduser** demande plus d'information que l'autre commande. En plus du complément d'information la commande va créer le répertoire de l'utilisateur et va demander a l'administrateur de définir un mot de passe. Ce mode interactif peut être inactif si vous passez en arguments l'ensemble de l'information requise pour la création de l'utilisateur. Tout comme lors de l'utilisation de **useradd** le système a créé un groupe avec le même nom que l'utilisateur. 

### Définition du groupe primaire

Vous ne désirez peut-être pas avoir cette prolifération de groupe associé avec l'utilisateur, si nous regardons la liste des groupes actuellement présent vous constaterez qu'il y a le groupe **users** déjà existant qui à le **GID** 100.

```bash
 # Liste les groupes avec le filtre user
admuser@srv01:~$ getent group | grep users
users:x:100:
```


Nous allons donc associé notre autre utilisateur à ce groupe comme groupe primaire , cette utilisateur ce nommera **bob**.

```bash
admuser@srv01:~$ sudo adduser --gid 100 bob
Adding user 'bob' ...
Adding new user 'bob' (1003) with group 'users' ...
Creating home directory '/home/bob' ...
Copying files from '/etc/skel' ...
Enter new UNIX password: 
Retype new UNIX password: 
passwd: password updated successfully
Changing the user information for bob
Enter the new value, or press ENTER for the default
	Full Name []: Bob Marley
	Room Number []: 
	Work Phone []: 
	Home Phone []: 
	Other []: chanteur
Is the information correct? [Y/n] y
 
 # Visualisation
admuser@srv01:~$ id bob
uid=1003(bob) gid=100(users) groups=100(users)
 
admuser@srv01:~$ getent group | grep bob
 # pas d'affichage donc aucun groupe bob ne fut créer
 
 # nous voyons que le groupe primaire est users
admuser@srv01:~$ ls -ld /home/bob/
drwxr-xr-x 2 bob users 4096 Apr 12 09:40 /home/bob/
admuser@srv01:~$ ls -la /home/bob/
total 20
drwxr-xr-x 2 bob  users 4096 Apr 12 09:40 .
drwxr-xr-x 7 root root  4096 Apr 12 09:40 ..
-rw-r--r-- 1 bob  users  220 Apr 12 09:40 .bash_logout
-rw-r--r-- 1 bob  users 3486 Apr 12 09:40 .bashrc
-rw-r--r-- 1 bob  users  675 Apr 12 09:40 .profile
```

Comme vous le constater le **UID** à incrémenté mais le groupe primaire n'est pas le nom de l'utilisateur mais **users**, si vous désiriez que l'ensemble de vos utilisateurs soit membre du groupe **users** il faudrait à chaque fois passer le paramètre **--gid users**, Ceci est ennuyeux car il est fort probable qu'un jours vous l'oubliez cette option, ou qu'un nouveaux collègues ne passe pas cette arguments, car la procédure de création des utilisateurs n'est pas suivit. Lors de la présentation de la commande **adduser** j'ai fait mention qu'il existe un fichier de configuration qui ce nomme **/etc/adduser.conf**.

Voici une partie du contenu du fichier de configuration :

```
[[OUTPUT COUPÉ]]
 
 # The USERGROUPS variable can be either "yes" or "no".  If "yes" each
 # created user will be given their own group to use as a default.  If
 # "no", each created user will be placed in the group whose gid is
 # USERS_GID (see below).
USERGROUPS=yes
 
 # If USERGROUPS is "no", then USERS_GID should be the GID of the group
 # `users' (or the equivalent group) on your system.
USERS_GID=100
 
[[OUTPUT COUPÉ]]
```

En modifiant le paramètre  **USERGROUPS** avec la valeur no , la variable **USERS\_GID** sera utilisé pour assigné le **GID** à l'utilisateur nouvellement créer résultat plus  besoin d'être vigilant pour la création des utilisateurs ils seront tous membres du groupe **users** par défaut. Bien entendu il est toujours possible de passer l'argument **--gid** ceci à prédominance sur le fichier de configuration. L'objectif était de vous amener à porter un œil sur ce fichier de configuration.

```bash
admuser@srv01:~$ sudo adduser peter
Adding user 'peter' ...
Adding new user 'peter' (1004) with group 'users' ...
Creating home directory '/home/peter' ...
Copying files from '/etc/skel' ...
Enter new UNIX password: 
Retype new UNIX password: 
passwd: password updated successfully
Changing the user information for peter
Enter the new value, or press ENTER for the default
	Full Name []: Peter Tosh         
	Room Number []: 
	Work Phone []: 
	Home Phone []: 
	Other []: Chanteur et Guitarist 
Is the information correct? [Y/n] y
admuser@srv01:~$ id peter
uid=1004(peter) gid=100(users) groups=100(users)
```

### Définition des fichiers copier dans le répertoire HomeDirectory

Telle que présenté dans les exemples précédent nous avons vu que le répertoire personnel de l'utilisateur est créé lors de la création de l'utilisateur. Comme nous le voyons à la ligne 5, vous pouvez constater que les fichiers provienne que les fichiers sont copiés depuis le répertoire **/etc/skel**. Ce répertoire contient l'ensemble des fichiers par défaut , voici les fichiers qui compose le répertoire **/etc/skel**:

* **/etc/skel**
	* **.bash\_logout** : fichier de configuration de __bash__ , ce fichier est appelé lors que la session __bash__ est terminé
    * **.bashrc** : fichier de configuration du __bash__ appelé lors du démarrage de chaque processus __bash__
    * **.profile**  : fichier de configuration chargé lors de la première connexion.


### Création d'un utilisateur de type système.

Lors de la création des autre utilisateurs nous avions toujours créer des utilisateurs de type régulier , la majorité du temps c'est le type d'utilisateur que vous allez ajouter au système. Par contre à des fin de connaissance nous allons voir comment créer des utilisateurs de type système, 99.99% c'est utilisateur sont automatiquement créé par le système de package lors de l'installation de logiciel, par contre si l'installation du logiciel est fait à la mains avec le code source il est probable que la création du l'utilisateur de service vous incombe ... Lors de la présentation des utilisateurs nous avions vu la particularité de ce type d'utilisateur :

* **UID** <= 499 (redhat) ou 999 (Ubuntu/Debian)
* **SHELL** : /bin/false ou /usr/sbin/nologin , du moins un interpréteur de commande qui ne permet pas les communications interactive
* **Mot de passe** : absent pour éviter toute connexion possible.

Pour réalisé la création de ce type d'utilisateur nous passons le paramètre __--system__ voici un exemple :

```bash
 # Création
admuser@srv01:~$ sudo adduser --system x3_srv_user
Adding system user `x3_srv_user' (UID 106) ...
Adding new user `x3_srv_user' (UID 106) with group `nogroup' ...
Creating home directory `/home/x3_srv_user' ...
 
 # Validation / présentation de l'utilisateur.
admuser@srv01:~$ id x3_srv_user
uid=106(x3_srv_user) gid=65534(nogroup) groups=65534(nogroup)
admuser@srv01:~$ getent passwd x3_srv_user
x3_srv_user:x:106:65534::/home/x3_srv_user:/bin/false
```

Comme nous pouvons le constater beaucoup moins de question , l'association de l'utilisateur avec le groupe **nogroup** un interpréteur de commande à **/bin/false** , un **UID** à 106 et aucune définition de mot de passe réalisé . Nous avons donc un utilisateur de service.
