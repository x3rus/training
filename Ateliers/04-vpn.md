
# Description 

Nous sommes au 4 ieme ateliers et vous comencez à avoir beaucoup de plaisir ;-), vous vous dites que malheureusement vous avez installez votre serveur sur un vieux PC et vous n'avez pas accès depuis l'extérieur. Bien entendu ceci vous rend triste et quand vous êtes chez des amis vous ne pouvez pas montrer votre fabuleux serveur. Nous allons donc corriger ce problème afin que vous soyez de nouveau heureux :-P.

Pour cette atelier nous mettrons en place une solution de VPN avec le logiciel [openvpn](https://openvpn.net), une fois le service en place vous serez en mesure de vous y connecter avec un ordinateur peu importe le système d'exploitation.

Le choix du logiciel de firewall ( iptables / firewalld ) dans le précédent atelier aura un répercution sur celui-ci. Attention à la documention choisie , de plus je vous invite a valider que la documentation trouvé est bien pour easyrsa 3.x et non la version 2. Je vous évite quelques pieges ici :D.

## Questions 

1. Qu'est-ce qu'un VPN ? 
2. Qu'est-ce qu'un système de certificat , root CA ? 
    * Suggestion de lecture : [https://fr.wikipedia.org/wiki/Infrastructure_%C3%A0_cl%C3%A9s_publiques](https://fr.wikipedia.org/wiki/Infrastructure_%C3%A0_cl%C3%A9s_publiques)
3. IP dynamique Vs ip Statique
3. Expliquer le systeme de port forwarding et le Natting.

# Opérations 

## Gandalf Configuration / Opération

* Réaliser l'installation d'OpenVPN sur le serveur
* Faire la génération de l'ensemble de clé ainsi que le diffie hellman
* Libre de le configurer en mode tunnel ( possibilité de communiquer uniquement avec le serveur gandalf ) ou bridge ( possibilité de communiquer avec l'ensemble du réseau derrière gandalf )
* Faire la configuration d'au moins 1 client, voir plus selon vos besoins. Pas de panique ceci peut être réalisé plus tard.
* Ajustez vos règles de firewall afin de permettre la communication sur ce nouveau service :).
* Assurez vous que le service démarre en même temps que le serveur.


Bien entendu si votre serveur VPN est dans votre réseau interne, vous devrez permettre la communication depuis internet vers votre serveur pour le service openvpn. 

### Votre routeur maison 

Si vous configurez le service openvpn avec le port par default vous devrez permettre à internet d'accéder au serveur Gandalf sur le port 1194 en **UDP**. Ceci sera réalisé en configurant un port forwarding.

Vous avez probablement une adresse ip dynamique à la maison, en d'autre mot mêe si vous notez votre adresse IP le matin il est possible quelle change dans la journée. Si c'est le cas et que vous désirez avoir un nom de domaine qui sera mis à jour lorsque votre ip change vous pouvez configurer votre routeur pour qu'il se mettre à jour avec [https://www.noip.com/](https://www.noip.com/). Ceci est l'équivalent de dyndns, malheureusement ce dernier n'offre plus de solution gratuite contrairement à no-ip. 
Attention , ce n'est pas tous les routeurs qui offre l'option, si c'est le cas alors vous devrez configurer gandalf pour qu'il réalise l'opération de mise à jour.

## Bilbo ou poste client Configuration / Opération

C'est bien d'avoir un serveur
 
## Gandalf et Bilbo 

# Atelier version plus compliqué 

# Objectif et critère de succès 

## Objectif 

## Critère de succès 


# Exemple du Résultat
