
# Description 

Nous allons maintenant ajouter un peu de sécurité sur cette machine. Bien que votre système est probablement dans un réseau interne ceci aura l'avantage en plus d'augmenter la sécurité, de vous permettre de savoir les ports réseaux utilisés. 
Dans un deuxième temps nous allons mettre en place un service qui vous offrira de la visibilité sur votre serveur :

![image](https://user-images.githubusercontent.com/2662304/48323827-b4c17580-e636-11e8-842c-0ee72fcb4115.png)

Car soyons réaliste, ça ne va pas toujours bien fonctionner ... :P Par contre avec ceci nous aurons plus de visibilité .

* Ouverture du port dans firewall

* ajout avec systemctl 
https://www.vultr.com/docs/installing-netdata-on-centos-7
* blocker le port + ssh port forward 
* Reouverture

* Logguer l'access sur un port TCP


## Questions 

* Réseautique :
    * Quelle est la différence entre TCP et UDP ?
    * Nommer 1 service qui utilise le protocol UDP .
    * Expliquer le port forwarding et le Natting .
    * Quelle est la différence entre des paquets qui sont drop et reject ?

* Expliquer l'information fournit par la commande **uptime** sur le load average , ci-dessous (0.06 , 0.12, 0.09)

    ```
    $ uptime
     17:02:06 up 9 min,  1 user,  load average: 0.06, 0.12, 0.09
    ```



# Opérations 

## Gandalf Configuration / Opération

### Par-feu

Installation ou activation du firewall sur la machine, vous avez le choix :

* firewalld ( commande firewall-cmd ) ceci est firewall par default sous Centos 7.
* Iptable ceci est le firewall que vous devrez installer manuellement si vous opté pour ce dernier.

Je ne sais pas lequelle vous suggérer, à ce jour iptables est partout mais demain ce il sera peut-être remplacé par firewalld, donc à voir de voir avec votre environnement de travail :).

Activer le firewall afin qu'il bloque tous les ports sauf **ssh** donc le port 22/tcp. **ATTENTION**, il y a un risque en cas d'erreur que vous n'ayez plus accès au serveur lors de l'activation, il est donc important que vous puissiez accéder à la console de la machine directement. 


### Application d'information du serveur ( Netdata )

* Installation
    * Faire l'installation de l'application [NetData](https://github.com/netdata/netdata), vous trouverez beaucoup d'exemple d'installation avec **docker**, essayez de ne pas prendre cette approche et de faire une installation native. 
    Je vous laisse chercher depuis la page github vous avez tous ce qu'il vous faut.

* Ouverture des règles de firewall 
    * Maintenant que nous avons un environnement sécuritaire :D, vous devrez ouvrir le port du service dans le firewall afin de valider le comportement.

* Operation diverts
    * Lister le(s) processus.
    * Explorer le fichier de configuration.
    * Redémarrer le serveur et voir si le service redémarre (ceci sera la prochaine étape)

* Configuration de netdata comme service
    * Afin d'avoir un serveur bien configurer nous aimerions avoir le service **netdata**  géré par systemctl  pour ce faire ajouter le service .
    * Activer le service au démarrage , rebooter pour confirmer que ceci fonctione et valider que le service démarre au boot.

## Objectif 

1. Configurer le firewall sur une machine
2. Ouvrire des port non standard sur le firewall
1. Installer un service en dehors de **yum** 
4. Ajouter un service dans systemctl et s'assurer qu'il démarre quand le système s'initialise
2. Voir s'il y a des règles de firewall qui bloque l'accès au service
3. Configurer les permissions du système de fichier

## Critère de succès 


# Exemple du Résultat
