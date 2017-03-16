
# Service EC2 

Fini la présentation haut niveau du service de cloud ou le listing des produits passons avec au service [AWS EC2](https://aws.amazon.com/ec2/details/) en "détail" (Petit rappel , je vais vous présenter ce que je connais, je vous invite à poursuivre ...)

Telle que mentionné [EC2](https://aws.amazon.com/ec2/details/) est le service de machine virtuelle d'Amazon, le terminologie utilisé par Amazon pour nommé cette machine est **INSTANCE**. Lors de la lecture de documentation vous aurez donc le terme **instance EC2**.
Nous allons débuter avec ce service ceci nous permettra de voir l'ensemble de l'écosystème qui l'entoure :

* réseautique
* Stockage 
* ...

Regardons de haut niveau ce qu'est une instance [EC2](https://aws.amazon.com/ec2/details/) :

* La première chose est de déterminer le lieu géographique où l'instance sera mise en marche. L'objectif est d'avoir le service le plus proche de vos utilisateurs afin que le temps de réponse soit optimal. Pourquoi traversé l'atlantique à chaque communication si la majorité de vos utilisateurs sont en France . Voici le lien définissant l'ensemble des [centre de données d'Amazon](https://aws.amazon.com/about-aws/global-infrastructure/) .
* Il existe plusieurs type d'instance [EC2](https://aws.amazon.com/ec2/details/) , chaque type à des spécifications particulière ( + CPU, + mémoire, + disque dur , disque dur avec + __d'I/O__ (__ssd__) , + GPU , ...) . Nous allons voir les différents type d'instance disponible dans la prochaine section . Bien entendu le prix change selon le type . L'objectif est de sélectionner celle selon vos besoins , elles sont regroupées :
    * __General Purpose__ : Utilisation général 
    * __Compute Optimized__ : Optimisation pour l'utilisation CPU
    * __Memory Optimized__ : Optimisation pour l'utilisation de la mémoire
    * __Accelerated Computing Instances__ : Optimisation avec accélération de traitement de calcul (__GPU__)
    * __Storage Optimizeda__ : Optimisation pour le stockage.
* Suite à la sélection de l'instance , nous avons le choix de "l'image" système d'exploitation / distribution que nous désirons avoir sur cette instance, nous avons les gros joueurs du jours. Voici une liste mais nous y reviendrons :
    * GNU/Linux : RedHat, Ubuntu , Debian , ... 
    * MS Windows : 2008 __R2__, 2012 
    * __FreeBSD__ 
    * Amazon/GNU/Linux : version de RedHat modifier 
    * __Solaris__ (à valider s'il est toujours présent)
* Nous allons bien entendu attribuer un peu de stockage à cette machine , il existe plusieurs type disponible comme toujours le prix varie :D c'est le truc 
    * __SSD__ 
    * Disque classique
    * Tape (__ouin__ j'avoue que je l'ai pas encore compris, mais je vais faire quelque recherche quand nous y serons :P)
* Configuration réseau, telle que mentionné plus tôt, il est possible de définir des segments interne à AWS ainsi que des règles de __firewall__ :
    * Segment réseaux __VPC__ 
    * Règles de __firewall__ de l'instance.
    * Assignation d'une adresse IP externe statique ou dynamique

Voici ce que je vous propose pour la présentation du service , nous allons faire la théorie sur les types d'instance __d'EC2__ ainsi que les images disponible (système d'exploitation) , nous laisserons le stockage ainsi que la partie réseau de côté dans un premier temps.
Juste pour avoir un jouet tous de suite avec quoi s'amuser :P , une fois la chose faite nous reviendrons afin de mieux comprendre la partie réseau , le stockage ainsi que les autres mécanismes autour __d'EC2__.

C'est partie !!

TODO Ajout imgs

## Type d'instance EC2

Nous devons définir quelle est le type de matériel que nous désirons avoir pour notre instance __EC2__ , voici la [documentation officiel Amazon sur le sujet](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html) .
Le choix est toujours difficile et le sera toujours , personne n'a envie de choisir une poubelle, nous désirons avoir de la PERFORMANCE. Bien entendu le prix varie en fonction de la puissance du système choisie. Ceci étant dit, rappelons nous le principe nous devons être plus flexible , optimiser la facture pour NOS besoin. Le choix de l'instance que nous réalisons au début n'est PAS obligatoirement le type d'instance que nous utiliserons dans le future. 
En effet nous verrons que nous pouvons modifier le type d'instance dans le temps que ce soit pour augmenter ou réduire cette dernière.

Mais avant de parler de changer une instance existante faudrait peut-être débuter par la création :P. 

Voici les types d'instance disponible aujourd'hui (2017-03-16) 

ICI ICI ICI

| Regroupement d'instance | Type d'instance disponible  |
|------------------------:|:---------------------------:|
| Utilisation général     | 
| Optimisation pour le calcule | 
| Optimisation pour la mémoire | 
| Optimisation pour le stockage| 
| Optimisation pour le calcule extrême | 

## Image -  Amazon Machine Image (AMI) EC2, système d'exploitation
## Stockage disponible pour l'instance EC2
## Amazon CloudWatch (https://aws.amazon.com/cloudwatch/)
## Auto Scaling (https://aws.amazon.com/autoscaling/)
## Resize instance (http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-resize.html)
## Elastic Load Balancing (https://aws.amazon.com/elasticloadbalancing/)
## VM Import/Export (https://aws.amazon.com/ec2/vm-import/)
## Systems Manager API

# idée raw 

* Présentation des services haut niveau
* Présentation de EC2
* explication des reseaux
    * ip static 
* Le système de conteneur dans aws
* route 53
* S3


# Alors Cloud ou pas cloud ?
