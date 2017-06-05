[comment]: <> ( gitlab : (sysadmin/training#10) )

# Amazon EC2 Container Service 


[Amazon EC2 Container Service](https://aws.amazon.com/fr/ecs/?nc1=h_ls) vous offre la possibilité d'avoir des conteneurs dans __AWS__ sans avoir l'ensemble de la gestion de l'OS sous votre charge.


## Fonctionnalité clé

* Déploiement simplifié grâce au système de conteneur de docker . ( ceci est implicite mais je voulais le mentionné )
* Amazon s'occupe de l'ensemble de la gestion du __cluster__  docker , ceci réduit considérablement la complexité de la mise en place .
* Vous avez la possibilité de définir un fichier de "Tâches" afin de déclaré les liens entre les conteneurs, les requis mémoire + processeur , ...
* Contrôle disponible via la API :D.
* Intégration avec le système de load balancer __Elastic Load Balancing (ELB)__, dans la définition des "tâches" il est possible de spécifier le __ELB__ , la configuration ce réalisera tous seul.
* Monitoring et conservation des logs avec le système __CloudWatch__.

## Prix 

Bonne nouvelle il n'y a pas de coût additionnel pour ce service, vous êtes facturez pour les ressources que vous utilisez ( exemple : __EC2 instances or EBS volumes__ )

# Référence 

* URL référence : 
    * [http://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)
