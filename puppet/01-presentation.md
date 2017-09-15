# Puppet ( Système de gestion de configuration ) 

**Puppet** est un système de gestion de configuration de système qui permet de gérer les systèmes d'exploitations :

* GNU/Linux 
* Mac OS X 
* Ms Windows

Il est existe version de puppet :

* **Version libre** qui permet de gérer les déploiements système et applicatif, et accepte les machines virtuelles type Amazon EC2.
* **Version commercial** permet en plus, de gérer les machines virtuelles VMware, d'avoir une interface graphique de gestion, d'automatiser et d'orchestrer les déploiements, d'avoir une plateforme de développement pour tous les environnements, de gérer individuellement les droits utilisateurs.

Puppet est principalement écrit en __Ruby__ un point fort pour certain , une contrainte pour d'autre :). Je vous laisserai faire votre choix, avec l'expérience.


## C'est quoi un système de gestion de configuration ?

Avant de parler de __puppet__ proprement dit , voyons c'est quoi un [système de gestion de configuration](https://fr.wikipedia.org/wiki/Gestion_de_configuration). L'objectif d'un gestionnaire de configuration est de permettre de gérer la configuration du système, j'espère que vous étiez assis en lisant cette phrase pleine de vérité :P. Au delà de cette tautologie , voyons des cas concrètes .

* **Permettre rapidement de mettre en place la configuration d'un système** ( système d'exploitation , logiciel , composante , ...) : Si vous avez quelques serveurs à mettre en place , combien de temps devez vous mettre sur le système pour qu'il soit opérationnel ? 4 heures , 2 heures ... ? Il est probable que le temps varie, selon le rôle du système. Avec un système de gestion de configuration, vous serez en mesure de définir des règles , des instructions qui décriront le processus de configuration qui sera réalisé sur le système. En d'autre mot l'idée est de délégué la tâches de l'ensemble du processus de configuration à une application.
* **Erreur de configuration** :  La plus grosse perte de temps,  lors de la mise en place d'un système est lorsqu'une erreur se glisse dans la configuration , que nous parlions d'une faute de frappe , d'une erreur d'inattention et on saute une section , ... Au mieux ça ne marche pas du tous alors on cherche , on cherche longtemps la virgule , le paramètre fautif. Autre situation, ça fonctionne mais pas dans une circonstance , donc ça fonctionne presque. Le signalement peut venir plusieurs semaine plus tard , donc pas planifié dans le projet , résultat difficile à gérer dans son temps . Le système de gestion de configuration applique bêtement , sans émotion , sans gueule de bois, même si l'OM à gagné la Ligue des Champions :P.
* **Uniformisation de la configuration** : Comme il n'y a pas d'opération manuelle réalisées la configuration est toujours intègre d'un système à l'autre , je ne dis pas toujours bonne :P , mais au moins si vous appliquez une configuration dans l'environnement de développement vous aurez la même configuration en production ! Vous serez donc en mesure d'identifier un problème de configuration dès l'environnement de développement. Bien entendu nous verrons comment paramétrer la configuration, car nous allouerons pas la même quantité de mémoire en développement qu'en production ...

# NOTE :

* __Puppet IDE__ : https://puppet.com/blog/geppetto-a-puppet-ide 


