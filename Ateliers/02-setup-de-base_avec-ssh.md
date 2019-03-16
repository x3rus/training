# Description 

Nous allons débuter la configuration de base du système, la mise en place de quelque outils qui nous servira par la suite. Nous sommes encore dans la phase de configuration initial. Nous ne parlons d'une configuration de production, car nous n'appliquerons pas l'ensemble des requis de sécurité, gardons en tête que ceci est un environnement de laboratoire / d'exploration.

## Information :

Nous allons faire la configuration d'utilisateurs , permettre a un utilisateur d'exécuter des commandes super utilisateur.
Faire la configuration du service ssh afin d'être en mesure d'établir une connexion à distance vers le serveur.

## Questions 

Quelques question relier à l'atelier qui vous donnera peut-être des pistes ou au moins vous offrira l'occasion de penser sur le sujets connex :

* Donnée la description / roles de ces répertoires :
    * /etc :
    * /var :
    * /usr :
    * /home :
    * /root :
    * /var/log : 
* Quelle est le nom du super utilisateur ? 
* Un utilisateur à un nom et un mot de passe, quelle sont les autres attributs des utilisateurs ?
* Un groupe à un nom, quelle sont les autres attributs des groupes ?


## Gandalf Configuration / Opération

* Mise à jour du système d'exploitation

1. Mise à jour du système
2. Faire un reboot une fois la mise à jour compléter

* Opération unique 

1. Extraire l'adresse ip du serveur.
2. Afficher l'espace disque utiliser et disponible .

* Utilisateur :

1. Création de 2 utilisateurs régulier : AAA et BBB
2. Assignation d'un mot de passe pour les 2 utilisateurs.
3. Création d'un groupe [maiar](https://fr.wikipedia.org/wiki/Maiar) et inclure l'utilisateur AAA dans ce groupe
4. Valider si le logiciel **sudo** est disponible, s'il n'est pas installer l'installer :D 
5. Configuration de **sudo**
    1. Configuration pour que les utilisateurs membre du groupe **maiar** puisse exécuter toute les commandes comme administrateur. Le mot de passe sera demandé lors de l'exécution de cette commande.

* Openssh 

1. Valider si le logiciel openssh est installé, s'il n'est pas installé ... Et bien l'installer :D.
2. Regarder si openssh est en cours d'execution
4. Limiter les personnes qui peuvent établir une connexion ssh sur la machine, uniquement les membre du groupe **maiar**
5. Assurez vous que l'utilisateur **root** ne peux pas établire de connexion ssh sur **Gandalf**

À partir de ce moment, nous allons oublier l'utilisateur **root** afin de n'utiliser que l'utilisateur **AAA** avec le préfix __sudo__ pour l'ensemble des commande d'administration.

* Installation des logiciels essentiel

1. Établir une connexion avec l'utilisateur **AAA**
2. Faire l'installation des logiciels suivants : 
    * git 
    * telnet 
    * vim : ou votre éditeur préféré :P 
    * tmux ( optionel ) : Optionel mais très agréable 
    * tcpdump 
    

## Bilbo ou poste client Configuration / Opération

* Openssh

1. Faire la création d'un clé ssh qui sera utilisé pour l'utilisateur AAA, libre à vous si vous voulez assigner un mot de passe. Je vous dirais que si le système est uniquement pour la formation pas besoin. Cependant ceci veut dire aussi que l'ensemble de la sécurité est sur la clé privé , il ne faut pas la perdre. 
2. Installer cette clé sur le serveur **Gandalf**, pour l'utilisateur AAA. Assurez vous que lors de l'établissement de la connexion ssh , ce n'est plus votre mot de passe qui est demandé mais la passephrase de la clé. Si vous n'avez pas mis de mot de passe la connexion sera direct.


* Installation des logiciels essentiel

1. Mise à jour du système d'exploitation
1. Faire l'installation des logiciels suivants : 
    * git et git-cola ( si vous voulez un ui ) 
    * telnet 
    * vim : ou votre éditeur préféré :P 
    * Openssh : 
    * tmux ( optionel ) : Optionel mais très agréable 
    * firefox 
    * tcpdump + wireshark
    * shutter : pour vos screenshots

 
## Gandalf et Bilbo 

* Réalisation d'un backup simple des configurations su **Gandalf**

1. Réaliser un fichier tar.gz des fichiers de configuration sur **Gandalf** 
2. Conserver ce dernier sur **gandalf** dans le répertoire de votre utilisateur , idéalement faire un répertoire :P.
2. Transferer le fichier à l'aide de scp de **gandalf** vers **bilbo**. Ceci nous offrira un "backup" externe.

# Atelier version plus compliqué 

1. Limiter la commande sudo afin de ne pas permettre à l'utilisateur AAA d'avoir un **shell** pour faire des commandes, les commandes suivantes ne devrais pas fonctionner :

    ```
    $ sudo su - 
    $ sudo -i root
    ```

2. Définir la clé ssh avec une passe phrase ( mot de passe sur la clé ) et mettre en place un agent ssh sur votre poste de travail ( Bilbo )  afin que le système ne vous le demande qu'une fois et pas à chaque connexion.

# Objectif et critère de succès 

## Objectif 

1. Être en mesure de faire la création d'un utilisateur et groupe.
2. Assigner un mot de passe à un utilisateur
3. Faire une configuration simple de sudo.
4. Installation de logiciels et mettre à jour le système
5. Redémarrer un service après une modification dans notre cas openssh
6. Utilisation de la commande tar pour faire une archive
7. utilisation de ssh et scp

## Critère de succès 

* **Gandlalf**

1. Avoir 2 utilisateurs utilisable sur la console, donc avec clavier sourie directement sur la machine.
2. Être en mesure d'établir une connexion ssh sur la machine **Gandalf** uniquement avec l'utilisateur **AAA**, car il est membre du groupe **maiar**.
3. Avoir la commande **sudo** fonctionnel pour l'utilisateur **AAA** ( exemple : sudo -l)
4. Avoir les commandes suivantes fonctionnel 
    * git --version
    * telnet --version
    * vim --version 
    * tcpdump --version


# Exemple du Résultat
