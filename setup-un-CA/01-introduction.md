# Description 

Nous allons mettre en place notre propre autorité de certification, donc l'équivalent de Digi cert , very signe , ... Bien entendu l'ensemble de la solution est purement libre !! Est-ce le meilleur système qui sera mis en place ?  NON !
Nous allons voir une solution purement manuel , ceci à des avantages indéniable pour le processus d'apprentissage. Nous allons voir vraiment les opérations , de mise en place et chaque opération nous demandera un peu de temps. Par contre l'ensemble sera des lignes de commandes ce qui va rebouter un peu le client / utilisateur . Il n'y a pas d'interface web pour les demandes / renouvellement , ... Il manque toute une logique pour le renouvellement automatique de certificat. Selon votre usage ceci peut être pratique, car c'est très Léger :D.

Si vous cherchez une solution complète , pour votre entreprise je vous invite à consulter :

* https://www.ejbca.org/
* http://www.openxpki.org/

Il y en a probablement d'autre disponible , mais j'ai fait très peu de recherche.

Pourquoi avoir son CA ?

* Pourquoi pas ? On peut le faire puis c'est libre.
* Parce que vous avait plusieurs service en SSL et pour chaque vous devez définir une exception dans votre fureteur ou client. Avec un CA vous n'aurez qu'un certificat à accepté et l'ensemble des certificats découlant de votre autorité de certification seront autorisé.
* Car vous chiffré tous et que vous générez une multitude de certificat.
* Parce que vous désirez authentifier votre interlocuteur, votre CA fera office de validation de l'identité de la personne qui l'utilise . Bon là faut mettre plus qu'un CA mais aussi un processus de validation de l'identité lors de la réception de la demande ... Mais bon l'idée est à !
* Ha puis je l'ai peut-être pas dit , mais juste **pour le FUN** et **apprendre**  !

* Voici la documentation de référence utilisé : [https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html](https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html)

Bon on commence , avant de perdre votre motivation :P ??? 

# Mise en place du l'autorité  de certification

L'opération sera réalisé en 3 étapes :

* Création de l'ultra MASTER root autorité de certification 
* Création d'une autorité de certification intermédiaire
* Création de certificat pour un serveur / service 

Donc bien entendu nous allons débuter avec le premier :D , la création du super **ROOT** 

## ROOT autorité de certification 

Cette autorité de certification représente notre CA primaire , nous allons suivre les meilleurs pratique de sécurité . Pour rappelle peut importe les mécanisme de sécurité que nous allons mettre en place la faille c'est **NOUS** . Quand je mentionne nous je veux dire l'activité humaine et les processus mis en place par ce dernier , j'exclus les actions telle que le vole volontaire , ... 

Le ROOT CA est normalement créer dans une environnement considéré comme sécuritaire , idéalement une machine qui n'a aucune connexion sur les internet, et qui à un disque chiffré . L'idéal aussi est que le système qui contient le ROOT CA soit complètement éteint et non disponible à moins que l'on est un réelle besoin qui ne doit jamais arrivé si vous avez bien fait vos chose ou uniquement une fois tous les 5 ans ou 3 ans. 

Bon nous ici on veut voir comment faire la création d'un CA on va pas s'exciter avec ça !!

