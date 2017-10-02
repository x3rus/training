
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

Je part du principe que vous êtes confortables avec le système de certificat , si ce n'est pas le cas , prenez quelque minutes pour consulter la vidéo sur le sujet sur ma chaîne youtube : [Comprendre httpS ( certificat et échange avec le serveur)](https://www.youtube.com/watch?v=DilZTPJFVH4&list=PLrspRZ5MjONw39vYQj-Ay6W_duE-8QuEq&index=2) et le texte [Mise en place d'un site httpS](../apache/serveur_web.mkd).


### Méthode classique 

Pour les personnes qui vont pas suivre les liens :P , il y a 2 partie :

* le certificat SSL : composé de 2 partie 
    * La clé publique du serveur 
    * La signature du centre de certification (verysign, godaddy, digicert, ... )
* La clé privé : qui est en combinaisons avec la clé publique, l'ensemble de la sécurité est basé sur cette clé.

Pour le reste vous consulterez réellement ma documentation ou vidéo.

Dans la méthode classique manuelle , le processus est simple :

1. Génération d'une pair de clés : 
    * Clé publique  : aussi appelé CSR (Certificate Signing Request), ce dernier contient les informations du serveur telle que le __Common Name__ L'URL associé au certificat.
    * Clé privé : ce fichier doit être sécurisé, car l'ensemble du processus de chiffrement est réalisé en se basant sur le fait que cette clé est PRIVÉ et que personne n'y a accès , sauf le service pour déchiffrer les communications.
2. L'humain transmet le CSR à l'autorité de certification , ce dernier signe la requête et transmet le certificat finale.
3. L'humain installe le certificat , la clé ainsi que la chaine de certificats du CA.

### Méthode Let's encrypt

Si nous regardons froidement l'ensemble du processus de génération et d'installation peut être automatisé , le problème réside dans la demande à l'autorité de certification. Let's encrypt se base sur le protocole [ACME](https://ietf-wg-acme.github.io/acme/draft-ietf-acme-acme.html) qui est encore en mode brouillon :P pour l'automatisation de la gestion des certificats. Libre a vous de lire le protocole, nous allons le voir à haut niveau pas besoin de vous taper la lecture.

Bien entendu, pour remplacer le processus de l'humain vous aurez besoin d'avoir un agent sur votre système qui réalisera les opérations. Si l'idée d'avoir un processus supplémentaire sur votre système vous décourage , prenez tous de même le temps de lire le texte ci-dessous. Particulièrement la section de l'implantation avec docker et nginx personnellement c'est ce qui m'a fait changer d'avis :P, vous reviendrez après sur la théorie :P.

Il y a 2 grande opération qui est réalisé par l'agent :

1. L'agent prouve au CA (Certificat Authority) de  Let's encrypt que le service web contrôle le domaine . **IMPORTANT** : vous ne pouvez utiliser Let's encrypt QUE et UNIQUEMENT pour des sites web publique, accessible depuis Internet !!
2. L'agent demande un certificat, renouvelle , révoque les certificats 


#### Validation du domaine 

Il existe 2 méthode pour prouver au Certificat d'autorité que nous sommes bien en charge du domaine , la première via le protocole HTTP(S) ou via DNS. Le problème avec le système de DNS est qu'il est probablement moins simple de l'automatiser. Bien entendu il est possible d'avoir du DNS dynamique pour faire l'opération cependant la méthode HTTP est plus fluide. Si vous contrôlez le site web , vous aurez tous en main pour mettre en place la configuration, alors qu'avec le DNS ça demandera une interaction avec l'autre équipe. 
Pour simplifier le document je vais me concentrer sur la validation HTTP , pour la partie DNS le beau RFC est la pour vous : [section 8.5. DNS Challenge](https://ietf-wg-acme.github.io/acme/draft-ietf-acme-acme.html#rfc.section.8.5)

#### Validation du domaine via Http et configuration serveur

Pour les amoureux des RFC, donc de la grosse théorie vous pouvez lire la section [8.3. HTTP Challenge](https://ietf-wg-acme.github.io/acme/draft-ietf-acme-acme.html#rfc.section.8.3). Pour les autres on va avoir une vue d'ensemble mais n'hésitez pas à consulter le RFC si vous avez l'impression que ça ne cole pas j'ai peut-être manqué quelque chose, j'ai pas la vérité infuse :D.

Donc passons à l'explication, la méthode est identique en HTTP ou HTTP**S**, dans le cadre de la configuration en __TLS__ vous devrez avoir une configuration "convenable" vous pouvez avoir un certificat auto-signé pour les besoins du processus initiale.

* Étape 1 

 efhkehfeh ERREUR ICI  hejhkfj

Lors du démarrage l'agent génère une pair de clé , en d'autre mot le **CSR** (Certificate Signing Request) ainsi que la clé privé , prendre note que la clé privé généré ne sort JAMAIS du serveur !! Le certificat sera généré avec un __Common Name__ ( nom du certificat ) fournit en paramètre . Vous devrez aussi spécifier le répertoire __DocumentRoot__ du site afin que l'agent dépose des fichiers qui seront utilisé lors de l'échange avec l'autorité de certification (Let's encrypt). 

Nous avons donc à cette étape l'installation de l'agent dans le site web (Racine du site) et la pair de clé que l'humain génère normalement manuellement.

* Étape 2 

L'agent communique avec le CA (Let's encrypt) afin de définir une méthode à utiliser pour la validation du nom de domaine , telle que mentionné plus haut, HTTP(s) , DNS, ... Il n'est pas encore claire la séquence ou comment le choix est réalisé , assurément le choix revient à l'agent , mais je n'ai pas encore identifier la séquence de la sélection.
Telle que mentionné plus haut, nous nous concentrerons sur la partie HTTP/HTTP(S).

* Étape 3 

Suite à la sélection de la méthode de validation en HTTP/HTTP(S) par l'agent le CA demande à l'agent de placer un fichier sous le site web , quand nous disons dans le site web pas de panique il ne va rien écraser. Il le définie sous les répertoires : __https://example.com/acme/__ et __https://example.com/.well-known/acme-challenge/__ 

Voici une représentation graphique du processus :

![](./imgs/howitworks_challenge.png)

Le fichier ci-dessus doit être définie à l'URL : __https://example.com/8303__ et doit contenir : __ed98__ , l'agent va aussi signer le fichier avec la clé privé. Comme nous signons avec la clé privé , toutes les personnes qui ont la clé publique pourrons valider la signature.

Je le répète si vous voulez le détail réelle consulter le RFC : [8.3. HTTP Challenge](https://ietf-wg-acme.github.io/acme/draft-ietf-acme-  4acme.html#rfc.section.8.3) !!

L'agent informe le CA que le fichier est maintenant présent pour la prochaine étape.

* Étape 4 


