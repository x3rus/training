
# Let's encrypt

Site web officiel : https://letsencrypt.org/
Référence wikipedia FR : https://fr.wikipedia.org/wiki/Let%27s_Encrypt

## Introduction pour let's encrypt

Nous allons voir le système de let's encrypt , ce projet est actif depuis plusieurs années déjà 3 décembre 2015 dans ça version bêta. J'ai mis du temps avant de vraiment adopté le système, car j'avais quelque inquiétude sur la sécurité . Bon quand je dis quelque inquiétude, j'ai pas lu l'ensemble du code pour essayer de trouver une faille ... je voulais simplement m'assurer de comprendre le fonctionnement du système au niveau de la documentation. 

Bon je parle de mes inquiétudes, mais j'ai oublié de vous dire c'est quoi ... :P

Let's Encrypt (abrégé LE) est une autorité de certification lancée le 3 décembre 2015 (Bêta Version Publique). Cette autorité fournit des certificats gratuits **X.509** pour le protocole cryptographique **TLS** au moyen d'un processus automatisé destiné à se passer du processus complexe actuel impliquant la création manuelle, la validation, la signature, l'installation et le renouvellement des certificats pour la sécurisation des sites internet. En septembre 2016, plus de 10 millions de certificats ont été délivrés.

En février 2017, Let's encrypt était utilisé par 13,70% du total des domaines français enregistrés.

En d'autre mot , pour vos site web au lieu d'utiliser un certificat auto signé, vous pouvez utiliser Let's encrypt qui vous fournira un certificat VALIDE dans le navigateur pour votre nom de domaine. Il y a quelques limitations , Let's encrypt ne peut être utilisé QUE pour les sites web publique, car ce dernier valide l'adresse IP du domaine , nous verrons le détail dans l'explication du protocole sous peu.

* **Objectif du projet**

Il y a plusieurs objectif au projet :

1. Permettre de sécurisé simplement des sites web sans Frais additionnel. 
2. Permettre d'avoir un certificat **TLS** sans intervention humaine.

Le deuxième point est particulièrement intéressant dans notre contexte de conteneur Docker et de l'ensemble de l'automatisation du processus de déploiement de système. La mise en place d'un certificat était toujours un "casse tête" pour savoir comment nous allions gérer cette particularité par système surtout si nous avions pas de certificat **wildcard** 

Nous verrons dans l'explication du fonctionnement que pour réaliser le deuxième point nous aurons besoin d'un agent sur le serveur qui réalisera la demande de certificat (**CSR**) , ainsi que l'installation . Ceci est réalisé grâce au protocole [ACME protocole](https://ietf-wg-acme.github.io/acme/).

* **Compatibilité avec les fureteurs**

Bien entendu certain vous encore se dire c'est un truc de barbu encore de logiciel libre , ça ne fonctionne qu'avec les fureteurs libres ... Et bien non, voici la liste des systèmes compatibles : https://letsencrypt.org/docs/certificate-compatibility/

Bien entendu si vous utilisez encore Windows XP SP1 , avec le Internet Exploser qui vient avec , je pense que vous avez de toute manière un plus gros problème que juste la non reconnaissance du certificat Let's encrypt. :P.


## Comment ça fonctionne ?

Bien entendu je vais réalisé une vulgarisation du processus , si vous voulez la version original , voici le lien  [https://letsencrypt.org/how-it-works/](https://letsencrypt.org/how-it-works/). 

L'exemple fournit reprend celui du site web , donc nous allons voir la mise en place d'un service web pour l'adresse [http://example.com](http://example.com) , à ce stade nous allons nous concentrer sur le protocole et non la configuration de apache ou nginx . Nous reviendrons sur le setup pour nginx dans la seconde partie .




