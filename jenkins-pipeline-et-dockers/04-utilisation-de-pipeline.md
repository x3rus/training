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
