# Présentation de Jenkins


En 2008 Jenkins devient LA solution pour l'intégration continue en remplacement de [CruiseControl](https://fr.wikipedia.org/wiki/CruiseControl). 

Le puis fort de Jenkins en plus de ça grande communauté est qu'il existe un nombre impressionnant de __plugins__ permettant d'étendre les fonctionnalités simple de l'outil.

Il est possible de lié Jenkins  avec __Subversion__ , __Git__ , et d'autre contrôleur de révision, il est possible de l'utiliser comme planificateur de tâche comme **cron** afin de réalisé des opérations périodique. Vous pouvez aussi lancer des exécutions à la demande ou utiliser des __webhook__ pour déclencher une opération par programmation. Nous allons couvrir quelque possibilité cependant telle que mentionné avec le nombre de plugins disponible les champs de possibilités sont nombreuses.

[Site web officiel de Jenkins](https://jenkins.io/). 

Que pouvons nous exécuter avec Jenkins ? 

* Des projets basés sur Apache Ant 
* Apache Maven 
* Des scripts arbitraires en shell Unix ou batch Windows. ( En d'autre mot N'IMPORTE QUOI :D ) 

L'application est développé en Java et sous [Licence MIT](https://fr.wikipedia.org/wiki/Licence_MIT)

## Architecture de Jenkins 

Avant de débuter avec l'installation voyons l'idée général du rôle de Jenkins et ça conception . 

Chaque tâche est une job, lors de l'exécution de la job nous exécutons un **build** , même si le résultat n'est QUE l'envoie d'un courriel ou le traitement de donnée, mais qu'aucune compilation n'est réalisé :D.

Jenkins fonctionne en mode master / slave :

* **Master** : reçoit les évènements que nous parlions d'évènement généré par le serveur Subversion, git, exécution d'un build manuellement par un utilisateur. Selon les critères saisie le système choisi un **slave** pour réaliser les opérations, nous verrons que nous utilisons les labels pour assigner des jobs au slave. Le serveur **master** contient l'ensemble des définitions **centralisé** contenant la description des opérations à faire ! Si tous les slaves sont déjà en utilisation le serveur va mettre en place un file d'attente.
* **Slave** : Le serveur slave est donc un agent du master, il réalisera l'opération demandé par le serveur Jenkins , bien entendu si le serveur Jenkins essaye d'exécuter une commande sur la machine elle doit être installé. Il est important donc d'avoir un __template__ , modèle pour que l'ensemble des serveurs slave est la même configuration. Comme Jenkins est développé en Java il est possible d'avoir des agents sur plusieurs type de système d'exploitation 

Voici une représentation graphique du fonctionnalité simple de Jenkins :

![](./imgs/jenkins-architecture.png)

Dans la pratique le serveur Jenkins peut être aussi être utilisé comme slave, cependant ceci est limitatif autant en terme de puissance que des possibilités d'avoir plusieurs architecture et / ou des lieux de traitement à plusieurs endroits.

Telle que mentionné plus tôt le nombre de plugins sont impressionnant : [https://plugins.jenkins.io/](https://plugins.jenkins.io/)

# Installation de Jenkins 

Bon nous orientons surtout la formation sur la pratique donc débutons avec l'installation , honnêtement je suis super paresseux et depuis l'arrivée **docker** ça n'a pas arrangé les choses. En d'autre mot je suis un bon DevOps / sysadmin :D , la paresse est un art mais demande beaucoup de temps pour la mettre en place :D. Nous réaliserons donc l'installation avec un conteneur !!

## Installation avec Docker

Bon voilà le problème en ce moment avec **docker** et les images officiel parfois elle ne sont plus disponible :-/ , originalement il y avait [https://hub.docker.com/_/jenkins/](https://hub.docker.com/_/jenkins/) , mais si vous regardez la page il y a le message :

> DEPRECATED
> 
> This image has been deprecated in favor of the jenkins/jenkins:lts image provided and maintained by Jenkins Community as part of project's release process
> The images found here will receive no further updates after LTS 2.60.x. Please adjust your usage accordingly.

Donc nous devons nous tourner vers l'image : [https://hub.docker.com/r/jenkins/jenkins/](https://hub.docker.com/r/jenkins/jenkins/) , ceci est l'image suggérer par la [documentation officiel de jenkins](https://jenkins.io/doc/book/getting-started/installing/#docker) . Il est évident que ceci n'aide pas l'utilisateur de docker mais que voulez vous ... :-/


