
# Présentation 

Pour commencer j'aimerais clarifier un point important, je ne suis pas un expert de **AWS (Amazon Web Services)** , j'ai eu la chance de jouer un peu avec et je partage ici mon expérience. Il risque donc d'y avoir des zones d'ombre auxquelles j'aurais de la difficulté à répondre , je m'en excuse d'avance. Par contre je pense pouvoir vous offrir une base pertinente vous permettant de vous débrouillez le moment venu :D. 

Ceci étant dit, nous allons faire de notre mieux !

De nos jours (2017 :P), si vous consultez un peu les offres d'emplois vous constaterez que la connaissance des technologies **cloud** est partout, que nous parlions de :

* [AWS - Amazon Web Services](https://aws.amazon.com/products/)
* [Google Cloud](https://cloud.google.com/products/)
* [Microsoft Azure](https://azure.microsoft.com/en-ca/services/)
* [Oracle Cloud](https://www.oracle.com/cloud/index.html)

Nous devons avoir cette corde à notre arc dans le future !! C'est une réalité à laquelle nous n'échapperons pas , est-ce une bonne chose ? La réponse est compliquée : 

* **OUI** :
    * Si vous êtes comme moi et que vous n'avez pas d'amour pour le matériel, ça évite beaucoup de problème :P. Pas besoin de trouver un collègue pour changer un CPU , une carte __PCI__ qui est problématique.
    * L'automatisation de la mise en place d'un nouveau système est simplifié plus besoin d'installer le serveurs , le câbler , identifier les câbles , ...
    * La possibilité de réaliser des déploiements dans plusieurs pays afin d'avoir un temps de réponse plus rapide , car plus proche du clients sans avoir la gestion d'un cabinet dans un centre de donnée.
    * La possibilité d'avoir une redondance d'équipement à moindre coût , ajouter ou réduire le nombre de serveurs dans un délais très court.
    * Avoir un API de fou pour vous permettre de faire plein de truc.
* **NON** :
    * Si vous êtes un paranoïaque sur la conservation de vos donnés, les géo-localisations des centres de données ne sont pas toujours en notre faveur. Si le centre de données est par exemple au États-Unis la législation est très peu clémente pour les citoyens non américains (__Patriot Acts__). Il est donc important de faire attentions.
    * Si vous êtes un administrateur réseaux, que vous appréciez la mise en place de __MPLS__, __QOS__, etc. Votre réalité risque d'être un peu chamboulé.

Sans allé dans le détail, il y a des pour et des contres ! Est-ce que l'utilisation du cloud est bon pour tous ... Je ne crois pas, par contre il y a clairement des avantages ! 
Nous allons voir les services disponibles chez Amazon, Google offre sensiblement les mêmes fonctionnalité ainsi que Microsoft Azure, la différence est dans les détail (prix , API , méthode de gestion , ... ). Suite à la présentation nous reviendrons sur la question : "Cloud ou PAS cloud ?!"

Pourquoi avoir choisie de présenter **AWS** au lieu d'un autre ? 

* **AWS** est disponible depuis plusieurs année et le service est mature, **l'API**  est très riche et il y a une grande communauté qui l'utilise (forum, exemple de script, ...) 
* **google** est très bien j'en suis certain , avec lui aussi un **API** riche , je crois que les 2 options sont très valide. Donc entre les 2 j'ai fait un choix.
* **MS Azure** est surement très bien aussi , je ne peux pas me prononcer sur **l'API** ne l'ayant pas du tous analysé. Bon mais le problème c'est pas le mot **azure** mais bien __microsoft__ :P . Et oui naturellement j'ai un moment de recule , après tant d'année :P.
* **Oracle cloud** ben c'est oracle :P , avec tous les combats contre le libre difficile de vouloir aller avec eux :P (c'est une prise de position :P ) . Par contre j'avais analysé rapidement les possibilités de **l'API** et ce dernier était clairement moins riche que **AWS ou google**. Je pense que la solution cloud d'oracle est intéressante si vous avez besoin d'utiliser une base de données __oracle__ pour le stockage. Sinon je ne vois pas trop l'intérêt mais je peux me tromper :P.

Bon ceci étant clarifier, débutons l'analyse de **AWS** !

## Présentation des produits 

Nous allons voir le nombre de services offert par Amazon est impressionnant , bien entendu je ne couvrirai pas tous , nous aurions assez de matière pour l'année :P , de plus j'ai pas les connaissances sur l'ensemble. 
Nous allons regrouper les services par fonctionnalité :

* [**Traitement, calcule** (**COMPUTE**)](https://aws.amazon.com/products/compute/)
    * [Amazon Lightsail](https://amazonlightsail.com/) : l'équivalent d'une machine virtuel privé hébergé chez Amazon , une quantité de mémoire , CPU , un disque dur et une quantité de transfert de données permis. La principale particularité est que les ressources sont réservé pour votre machine. Vous pouvez consulter la [liste des fonctionnalités](https://amazonlightsail.com/features/). 

        | Prix/mois  | Mémoire | CPU     | Disque Dur | Transfert |
        |-----------:|:-------:|:-------:|:----------:|:---------:|
        |$5          |  512 MB |  1 Core | 20 GB SSD  | 1 TB *    |
        |$10         |  1 GB   |  1 Core | 30 GB SSD  | 2 TB *    |
        |$20         |  2 GB   |  1 Core | 40 GB SSD  | 3 TB *    |
        |$40         |  4 GB   |  2 Core | 60 GB SSD  | 4 TB *    |
        |$80         |  8 GB   |  2 Core | 80 GB SSD  | 5 TB *    |
            Prix pour AWS Lightsail (2017-03-08)
    * [Amazon EC2](https://aws.amazon.com/products/compute/#ec2) : Probablement le service d'Amazon le plus connu qui permet d'avoir une machine sur demande, la machine virtuel peut être initialisé pour 1 heure ou 2 puis éteinte la facturation est réaliser uniquement pour le temps d'utilisation. 

# idée raw 

* Présentation des services haut niveau
* Présentation de EC2
* explication des reseaux
    * ip static 
* Le système de conteneur dans aws
* route 53
* S3


# Alors Cloud ou pas cloud ?
