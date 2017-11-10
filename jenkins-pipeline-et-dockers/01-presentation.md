# Jenkins PipeLine et Docker

Lors de la présentation de Jenkins nous avons fait une démonstration de l'outil je dirait de manière classique , nous avons mis en place Jenkins et définie des slaves que nous avons configurer. Dans les slaves nous avions permis l'utilisation de Docker grâce au commande **docker \*** , cependant nos conteneurs avec la fonctionnalité docker avait un problème. Nous avions notre conteneur en exécution continuel , alors que l'avantage du système de conteneur est d'avoir une démarrage des services au besoin. Nous allons donc voir comment modifier notre configuration afin de permettre que ceci soit plus dynamique selon le besoin . En d'autre mot suivre les meilleurs pratique actuellement. 

Avant de voir ce coté du démarrage dynamique des conteneurs , j'aimerai que l'on voit le concept de Pipeline qui est aussi la nouvelle mode de configuration de Jenkins ... allé n'attendons plus c'est PARTIE !!!!

Référence de documentation : 

* https://jenkins.io/doc/book/pipeline/
* a revalider dans le temps
    * https://dzone.com/articles/jenkins-pipeline-plugin-tutorial

## Avant de débuter

Avant de débuter la configuration nous allons faire 2 choses .

1. Préparer notre environnement de travail 
2. Établir le cas d'utilisation 

Je fais la distinction entre les 2 , ceci vous permettra de vous organiser tout seul si finalement le cas que je propose ne vous intéresse pas :P .

### Préparation de l'environnement 

Oui malheureusement pour pouvoir faire tous ça faut d'abord ce préparer , comme toujours nous allons utiliser Docker pour l'exercice , je vas passer très très rapidement sur ce point. Je vous invite à consulter la [première session sur Jenkins](../jenkins/01-presentation.md) pour avoir l'ensemble des instructions. 

En fait j'aurais réutilisé le setup de la dernière fois mais j'ai détruit l'ensemble des volumes créer donc ... pas le choix de reprendre. Nous allons mettre 3 conteneurs :

* Jenkins :D
* Un slave Jenkins avec le support de dockers actif en permanence , nous utiliserons les instructions docker run , docker-compose , ... Pour initialisé les conteneur. Nous verrons par la suite l'autre méthode pour avoir quelque chose de plus dynamique
* un serveur gitlab , vous pouvez utilisez le votre libre à vous, voir github , mon objectif est d'avoir un écosystème complet fonctionnel avec peu de dépendance externe.

Le fichier docker-compose est disponible : [dockers/docker-compose.yml](./dockers/docker-compose-v1.yml)

Avant de démarrer le conteneur je vais créer le répertoire :

```bash
$ sudo mkdir -p /srv/docker/x3-jenkinsWithPipe-f/jenkins-data
$ sudo chown 1000:1000 /srv/docker/x3-jenkinsWithPipe-f/jenkins-data
```

Démarrons le conteneur jenkins nous devrons refaire la configuration initialisé en mettant en place les plugins de base , ... Tous ça fut couvert dans le première session , je vais aussi faire la configuration du gitlab couvert lors de la [présentation de gitlab](../gitlab/01-presentation.md)

Étapes réalisées :

1. Setup initial jenkins avec plugins recommandés
2. Setup initial Gitlab root (mot de passe par défaut) 
3. Création d'un utilisateur dans gitlab avec possibilité de créer des projets...
4. Configuration du slave, comme ceci est peut-être moins évident un peu d'information
    * Vous avez la clé privé du slave disponible dans le fichier [data/jenkins-nodes_rsa](./data/jenkins-nodes_rsa)
    * Je aussi réalisé une copie d'écran [01-jenkins-setup-slave-dck01.png](./imgs/01-jenkins-setup-slave-dck01.png)



## Les Pipelines avec Jenkins

Nous avons vue lors des sessions passées l'utilisation de Jenkins avec le système de conteneurs , ceci fonctionnait très bien cependant comme nous avons pu le voir la segmentation des actions n'est pas obligatoirement claire en lisant le logs de résultat. Si nous avions une équipe de développement , de QA ou des personnes en charge de l'infrastructure quand il y a une erreur une personne doit être en mesure d'analyser le log pour le transmettre à la bonne équipe. Vous me répondrez probablement, mais ce n'est pas la tâches du DevOps de faire ça , heu ... oui et non . Nous pourrions le dire ainsi c'est le DevOps à le faire puis de transmettre l'information. Mais un bon DevOps c'est quoi , c'est une personne super paresseuse , excusez on dit habituellement une personne qui optimise sont temps :P.

Pour optimiser notre temps l'idée est de réussir à aviser les bonnes personnes pour la bonne action ! Notre problème aujourd'hui est que nous avons une tâches ("build") qui réalise l'ensemble de l'opération nous pouvons transmettre un courriel à la fin mais à qui ? QA , Dev, Infra , Ops , ... 

Aujourd'hui ça va on fait le build et la validation , mais que ce passerez t'il si nous avions :

* la compilation de l'application
* La création du conteneur
* La réalisation de la validation
* Le déploiement sur un environnement de test d'intégration
* La deuxième passe de test

Comment si ceci est dans 1 build informer les bonnes personnes. Jenkins offre traditionnellement le mécanisme qui nous permet d'appeler d'autre tâches à la fin d'un tâches et de définir des conditions . Cependant si vous l'avez déjà utilisé dans le passez vous savez comme moi que ce n'est pas simple de visualiser le statu de l'ensemble des tâches de d'identifier l'imbrication des ces dernières pour le commun des mortelles.

Le concept de pipe fut mis en place afin de facilité le mécanisme. Nous allons donc convertir notre mécanisme avec les pipes.



### Présentation du concept de Pipeline

TODO : à compléter

* https://jenkins.io/doc/book/pipeline/

### 
