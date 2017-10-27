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
* Parce que Let's encrypt est pas disponible pour un usage interne, non publique ... (voir formation Let's encrypt)
* Ha puis je l'ai peut-être pas dit , mais juste **pour le FUN** et **apprendre**  !

* Voici la documentation de référence utilisé : [https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html](https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html)

Bon on commence , avant de perdre votre motivation :P ??? 

# Mise en place du l'autorité  de certification

L'opération sera réalisé en 3 étapes :

* Création de l'ultra MASTER root autorité de certification 
* Création d'une autorité de certification intermédiaire
* Création de certificat pour un serveur / service 

Donc bien entendu nous allons débuter avec le premier :D , la création du super **ROOT** 

### Version docker et Version native

Pour réaliser l'opération je vais faire la création d'un CA dans un conteneur docker , la principale raison et l'isolation de la configuration pour ne pas polluer mon environnement environnement de travail avec du matériel de formation. De plus ceci nous assurera que ceci fonctionne peut importe où vous utiliserez ce conteneur. 

Donc je vais fournir le Dockerfile ainsi que le docker-compose , ceci nous offre aussi l'avantage d'avoir l'extraction de l'essentiel voici donc le requis :

* **openssl** : Le seule requis est d'avoir le logiciel openssl de présent !
* **Éditeur de texte** : De plus vous devez avoir VI ou un autre éditeur moins puissant ;-) pour éditer du texte  

Donc voici le résultat du Dockerfile :

```
FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y openssl vim
```

Bon pour les puristes OUI je ne devrais pas mettre __vim__ , dans mon conteneur mais comme je veux faire une formation le plus proche d'une installation sur un serveur sans docker ça simplifiera la présentation. 

Voici le docker-compose :

```
version: '2'

services:
    ca:
        image: x3-my-ca
        build: .
        container_name : 'x3-CA-f'
 #      restart: unless-stopped
        volumes:
            - "./volumes/my-CA:/root/"
        networks:
            - none

networks:
    none:
        external: true
``` 

Comme vous pouvez le voir j'ai désactivé le réseau du conteneur car non requis pour l'opération j'optimise la "sécurité" !! 
J'ai aussi associer le répertoire personnel de l'utilisateur root avec le répertoire local ./volumes/my-CA, j'aime pas mettre des valeurs relative comme ça mais bon ...

Nous avons l'ensemble du settup on démarre :D.

```bash
$ docker-compose build
[ ... ]
 ---> bd7d45f8d433                     
 Removing intermediate container 20b7bba34ec9                                   
 Successfully built bd7d45f8d433        
 Successfully tagged x3-my-ca:latest   

$ docker-compose run ca bash
```

En utilisant **docker-compose run** ça me permet d'avoir un conteneur actif uniquement lors de son utilisation en mode interactif, par la suite le système éteint le conteneur.

## ROOT autorité de certification 

Cette autorité de certification représente notre CA primaire , nous allons suivre les meilleurs pratique de sécurité . Pour rappelle peut importe les mécanisme de sécurité que nous allons mettre en place la faille c'est **NOUS** . Quand je mentionne nous je veux dire l'activité humaine et les processus mis en place par ce dernier , j'exclus les actions telle que le vole volontaire , ... 

Le ROOT CA est normalement créer dans une environnement considéré comme sécuritaire , idéalement une machine qui n'a aucune connexion sur les internet, et qui à un disque chiffré . L'idéal aussi est que le système qui contient le ROOT CA soit complètement éteint et non disponible à moins que l'on est un réelle besoin qui ne doit jamais arrivé si vous avez bien fait vos chose ou uniquement une fois tous les 5 ans ou 3 ans. 

Bon nous ici on veut voir comment faire la création d'un CA on va pas s'exciter avec un excès de sécurité mais je vous informe !! 

Nous allons travailler dans le répertoire **/root/ca** bien entendu personne autre que l'administrateur n'a besoin d'y avoir accès :D.

```bash
$ mkdir /root/ca
```

* Création de la structure des répertoires , les fichiers __index.txt__ et __serial__ sont des fichiers de base de donnée plat qui servirons à conserver l'information sur les certificats signés.

```bash
$ cd /root/ca
$ mkdir certs crl newcerts private
$ chmod 700 private
$ touch index.txt
$ echo 1000 > serial
```

Bien entendu le répertoire private contiendra des clé privé il est important de s'assurer que les droits d'accès au fichier sont adéquat .

### Fichier de configuration du ROOT CA

Nous allons maintenant faire la création d'un fichier de configuration pour notre ROOT CA , nous allons partir du fichier [root-config.txt](./data/root-config.txt) , et nous allons le parcourir. 

Je vous invite à le télécharger ( il est dans le dépôt git avec l'ensemble ) et de l'ouvrir votre éditeur préféré et nous allons passer les sections ensemble. 

Nous allons copier ce fichier dans le répertoire /root/ca en lui donnant le nom /root/ca/openssl.cnf

```bash
$ cp root-config.txt /root/ca/openssl.cnf
```

#### Configuration principale


* CA 

```
[ ca ]
 # `man ca`
default_ca = CA_default
```

Cette section est obligatoire, elle indique d'utiliser la section **CA\_default** que nous allons voir dans un instant .

* CA\_default

```
[ CA_default ]
 # Directory and file locations.
dir               = /root/ca
certs             = $dir/certs
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
RANDFILE          = $dir/private/.rand

 # The root key and root certificate.
private_key       = $dir/private/ca.key.pem
certificate       = $dir/certs/ca.cert.pem

 # For certificate revocation lists.
crlnumber         = $dir/crlnumber
crl               = $dir/crl/ca.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

 # SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_strict
```

Si vous avez décidé de mettre l'ensemble des fichiers dans un autre répertoire que **/root/ca** ajuster la variable **dir** qui définie la racine de notre autorité de certification. Comme vous pouvez le voir nous définissons le lieux de l'ensemble des fichiers (certificats, numéro de série, la clé privé du CA , la définition des la liste des certificats révoqué (CRL) , le nombre de jour par défaut d'un certificat , ... ) De plus nous allons établir les restrictions pour l'autorité de certification intermédiaire via l'instruction **policy = policy\_strict** , voici la section de la politique.

* policy\_strict

```
[ policy_strict ]
 # The root CA should only sign intermediate certificates that match.
 # See the POLICY FORMAT section of `man ca`.
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
```

Cette politique sera donc utilisé pour faire la création du ou DES autorité de certification intermédiaire , nous y appliquons une restriction, le pays , la province et l'organisation (la compagnie)  doivent être la même . Nous allons avoir pouvoir définir un département ou unité d'affaire de l'entreprise différente un nom ainsi qu'un courriel distinct. 

* policy\_loose 

```
[ policy_loose ]
 # Allow the intermediate CA to sign a more diverse range of certificates.
 # See the POLICY FORMAT section of the `ca` man page.
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
```

Voici la politique qui sera appliqué pour les certificats qui seront signé par l'autorité de certificat secondaire , comme vous pouvez le voir l'ensemble est optionnel . Donc si notre unité d'affaire est en Allemagne , en Australie , en Algérie le certificat pourra être émis par notre autorité de certificat intermédiaire sans problème.

* req

```
[ req ]
 # Options for the `req` tool (`man req`).
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only

 # SHA-1 is deprecated, so use SHA-2 instead.
default_md          = sha256

 # Extension to add when the -x509 option is used.
x509_extensions     = v3_ca
```

Ceci nous permet de définir les valeurs pour les requêtes de certificat, nous avons ici le nombre de bits utilisé 2048 commence tranquillement à être limite comme taille de clé, mais bon :P, 4096 ça serait mieux  . Les chaines de caractère pour les informations seront codé en UTF-8, ... L'entrée distinguished\_name permet de définir ce que doit obligatoirement contenir une requête de certificat, nous y arrivons.

* req\_distinguished\_name 

```
[ req_distinguished_name ]
 # See <https://en.wikipedia.org/wiki/Certificate_signing_request>.
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

 # Optionally, specify some defaults.
countryName_default             = CA
stateOrProvinceName_default     = Quebec
localityName_default            = Montreal
0.organizationName_default      = x3rus
organizationalUnitName_default  = 
emailAddress_default            =
```

Voici ce que nous allons demander obligatoirement pour nos certificats donc nos requêtes de certificats : Le pays, La province , La ville, le nom de l'organisation, l'unité d'affaire , le nom du site ou service , le courriel . Comme vous pouvez le voir ceci est bien standard, mais l'idée ici est de constaté que en soit vous pourriez ajouter des informations propre à vous telle que le role , le nom du demandeur , ... Attention par contre ces informations seront aussi visible dans le certificat final donc il faut penser que ce sera PUBLIC si le certificat est transmis telle que pour un site web.

Lors de la création d'un nouveau certificat au lieu de saisir l'information manuellement vous pouvez saisir des valeurs par défaut qui seront proposé à la personne qui réalise le certificat. Comme vous pouvez le voir j'ai saisie quelque valeur propre à moi , car c'est assez ennuyant de toujours saisir la même chose :P.

#### Configuration applicable sur demande

Les sections suivante sont des configurations qui seront appliquer sur demande lors de besoin spécifique , c'est des paramètres spécifique qui sont requis pour certain type de certificat , bon j'ai déjà tendance à m'étendre un max si en plus on explique chaque paramètre on s'en sortira pas. Je vous laisse faire vos recherches pour cette partie :P , si vous voulais avoir plus de détail. 

* Paramètre des CA

```
[ v3_ca ]
 # Extensions for a typical CA (`man x509v3_config`).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_intermediate_ca ]
 # Extensions for a typical intermediate CA (`man x509v3_config`).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
```

Ceci est les 2 sections pour les autorités de certification , nous avons le ROOT ca ainsi que celui pour l'intermédiaire, ils sont  presque pareil sauf le __basicConstraints__  l'intermédiaire à un paramètre en plus. Cependant les 2 peuvent réalisé des signatures, des révocations de certificat , ... 
Je vais porter votre attention sur l'option **CA:true** qui indique que c'est un certificat CA, je vais y revenir.


* Paramètre pour un utilisateur

```
[ usr_cert ]
 # Extensions for client certificates (`man x509v3_config`).
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection
```

Nous avons ici les configurations si vous réalisez des certificats pour vos utilisateurs , une utilisation très commun est de fournir un certificat à un utilisateur pour une connexion VPN. Ceci permet en plus d'avoir l'authentification Nom utilisateur / Mot de passe , de valider sont identités avec un "carte" d'identité nommé certificat. 
Autre utilisation aussi pour des accès wifi , un utilisateur pourrais avoir un certificat assigné à lui sur ça machine pour ne pas avoir à d'authentifier quand il rentre sur le réseau wifi , etc etc.

Je vais revenir tous de suite sur la **basicConstraints** qui à l'identifiant **CA:FALSE**, donc le certificat qui est généré pour cette utilisation n'est pas un CA. Bon jusque vous voyez peut-être pas pourquoi j'insiste autant la dessus, il y a quelque année une autorité de certification avait fait une erreur et avait permis que les certificats qu'il émettait n'avait pas ce flag à FALSE. Résultat avec 1 certificat attribué par cette autorité la personne pouvez créer autant de certificat qu'il le désirer . :D 

* Paramètre d'un certificat pour serveur 

```
[ server_cert ]
 # Extensions for server certificates (`man x509v3_config`).
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
```

Globalement la même chose que pour une utilisateurs :D.

* Paramètre pour la révocation d'un certificat 

```
[ crl_ext ]
 # Extension for CRLs (`man x509v3_config`).
authorityKeyIdentifier=keyid:always

[ ocsp ]
 # Extension for OCSP signing certificates (`man ocsp`).
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning
```

### Création des clé du ROOT CA

Bon maintenant que l'on a vue le fichiers de configuration je présume que vous avez hâte que l'on commence réellement à créer des choses :D , pas de panique ça arrive .

Nous allons faire la génération de la clé privé avec une clé de 4096 bits 

```bash
$ cd /root/ca
$ openssl genrsa -aes256 -out private/ca.key.pem 4096
Generating RSA private key, 4096 bit long modulus                              
.......................................++                                      
............................................................................................................................................................................................................................................................................................................................................................++     
e is 65537 (0x10001)                   
Enter pass phrase for private/ca.key.pem:                                      
Verifying - Enter pass phrase for private/ca.key.pem:

$ chmod 400 private/ca.key.pem
```

Nous devons associé un mot de passe à cette clé , bien entendu définir un bon mot de passe idéalement généré , voici ce que j'ai mis : mon\_super\_root\_ca . C'est très mauvais mais bon c'est pour un usage dans la formation.

Personne ne doit être en mesure de consulter cette clé , nous ajustons ou nous assurons que les permissions sont adéquat.

### Création du certificat pour le ROOT CA

Nous avons à présent une clé pour notre autorité de certificat, nous allons faire la création d'un certificat pour ce dernier donc la partie clé publique. 

**ATTENTION**: Nous allons définir une date d'expiration pour notre ROOT CA, cette dernière doit être loin dans le temps, car quand notre ROOT CA aura expiré l'ensemble des certificats que ce dernier a signé seront jugé invalide . Même s'ils ont une date plus loin dans le temps, et oui effectivement nous devrons ré attribuer des certificats certificats avec le nouveau CA. C'est une réaction en chaine , si un membre de la chaine de validation n'est plus jugé comme valide l'ensemble des certificats émis par ce dernier sont jugé invalide.

Si vous n'avez pas encore copié le fichier de configuration __openssl.cnf__ présenté dans la section précédente ce serait le bon moment sinon la commande utilisera le fichier par défaut du package donc ne contiendra pas les spécificités définie pour le CA.

Voici la commande : 

```bash
$ cd /root/ca
$ openssl req -config openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem

Enter pass phrase for private/ca.key.pem:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
 -----
Country Name (2 letter code) [CA]:
State or Province Name [Quebec]:
Locality Name [Montreal]:
Organization Name [X3rus]:
Organizational Unit Name []:Sec
Common Name []:ROOT CA
Email Address []:sec@x3rus.com

$ chmod 444 certs/ca.cert.pem
```

### Vérification du ROOT CA certificat

Comme nous savons tous avoir des points de contrôle c'est important, car c'est simple quand on fait quelque chose de nouveau souvent on se trompe :P . 
Ce qui est ennuyant de le constater uniquement à la fin :).

Donc validons notre certificat :

```bash
$ openssl x509 -noout -text -in certs/ca.cert.pem
```

**YEAHH** merci Thomas plein de output , mais ça vous parle pas ... donc voici les points que je désire valider :

* La section : Signature Algorithme 
    * Validity : La période de validité du certificat , si j'ai fait une erreur sur la date, comme je vais signer l'ensemble des certificats avec ce dernier et telle que mentionné plus tôt un fois invalide l'ensemble des certificats signé par lui deviennent invalide c'est important que ce soit bon !!
    * Public-Key  : Je valide que la taille de ma clé est bonne !
    * Issuer : Je confirme que l'email et autre information sont valide, vous vous rappeler nous avons défini une restrictions pour notre autorité de certification intermédiaire . Nous devons donc avoir de bonne valeur ici :D.
    * Subject : Comme c'est un auto signé , ce doit être la même chose !!
    * X509v3 : Le certificat doit avoir la configuration \[ v3\_ca \] que nous avions définie dans le fichier de configuration en d'autre mot vous devez retrouvé les entrés x509v3 avec le flag **CA:TRUE**

Donc reprenons la commande avec un peu de couleur :

```bash
$ openssl x509 -noout -text -in certs/ca.cert.pem  | egrep --color  'Signature Algorithm|Validity|Public-Key|Issuer|Subject|X509v3|$'
```

![](./imgs/01-view-root-ca.png)


Nous avons donc terminé avec le ROOT CA , je comprend que pour le moment vous voyez un peu déconcerté car finalement c'est presque que comme un certificat auto signé ... j'en convient , mais il y a le flag **CA:TRUE** :P . Sans farce effectivement en fait nous allons voir que le mécanisme de certificat est tous simple que c'est toujours le même principe qui s'applique . En conservant ça le plus simple possible la validation est d'autant plus simple .



## Autorité de certification  Intermédiaire


