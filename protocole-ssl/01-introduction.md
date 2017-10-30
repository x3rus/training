# Mise en place d'un site en httpS

La sécurisation des communication est plus que critique de nos jours, nous désirons que les informations non publique ne soit lisible que par les personnes autorisées. Le protocole **HTTP** est un protocole non sécurisé , l'ensemble des paquets réseaux sont lisible (non chiffré) , si une personne est sur votre réseau et peut intercepté les communications il peut lire l'ensemble du trafic. Le protocole **httpS** règle le problème en chiffrant les communications entre le client (fureteur) et le serveur (apache) , résultat le trafic ne peut pas être lu.

Sous __Ubuntu__ le module **ssl** est inclut lors de l'installation du pacquage **apache2**, sous __RedHat/CentOS__ vous devez installer le module **mod_ssl** spécifiquement. Nous allons prendre quelques minutes pour voir la théorie autour du système de certificat __SSL/TLS__ , car d'expérience j'ai constaté que pour beaucoup le concept de certificat __SSL__ est floue alors que l'ensemble de nos communications sont assurées par ce système. Par la suite nous mettrons en place la configuration dans apache.

## Théorie du fonctionnement des certificats 

Nous allons donc voir comment tous ceci fonctionne, je vais essayer d'y allé en détail mais tranquillement ! Je crois qu'il est important de comprendre ce fonctionnement. Comprendre le fonctionnement des certificats permet de mieux diagnostiquer les problèmes comme administrateur mais aussi comme utilisateur.

Ces certificats permettent d'effectuer des opérations cryptographiques, comme le chiffrement et la signature numérique qui offrent les garanties suivantes lors des transactions électroniques :

* **Confidentialité** : elle garantit que seul le destinataire (ou le possesseur) légitime d'un bloc de données ou d'un message peut en avoir une vision intelligible ;
* **authentification** : elle garantit à tout destinataire d'un bloc de données ou d'un message ou à tout système auquel tente de se connecter un utilisateur l'identité de l'expéditeur ou de l'utilisateur en question ;
* **intégrité** : elle garantit qu'un bloc de données ou qu'un message n'a pas été altéré, accidentellement ou intentionnellement ;
* **non-répudiation** : elle garantit à quiconque que l'auteur d'un bloc de données ou d'un message ne peut renier son œuvre, c'est-à-dire prétendre ne pas en être l'auteur.


### C'est quoi un Certificat ?

Lors de la mise en place d'un site web **https** , nous déclarons une pair de clé , le **certificat** et **la clé privé** , ceci suit le principe de [cryptographie asymétrique](https://fr.wikipedia.org/wiki/Cryptographie_asym%C3%A9trique). La cryptographique asymétrique est utilisé dans bien des cas (clé __ssh__ , ...) , le système **HTTPS** s'appuie sur ce principe , nous allons voir les détails.

Le principe du système de chiffrement asymétrique est basé sur une pair de clé : 

* Une clé publique qui est distribué à tous 
* Une clé privé , l'ensemble de la sécurité réside dans cette clé il est primordiale de la conserver dans un lieu sécuritaire. Non lisible par tous

![250px-Public-key-crypto_svg.png](./imgs/250px-Public-key-crypto_svg.png)

**ATTENTION** : lors de la génération des clés leur association est **unique**, en d'autre terme si vous perdez une des deux clé il est **impossible** de régénéré l'une d'elle !!

Le système de pair de clé ( [cryptographie asymétrique](https://fr.wikipedia.org/wiki/Cryptographie_asym%C3%A9trique) ) est en contraste avec le système de chiffrement à une clé ( [cryptographie_symétrique](https://fr.wikipedia.org/wiki/Certificat_%C3%A9lectronique#Rappels_sur_le_chiffrement) ) où l'ensemble des utilisateurs connaisse la clé. 
Voici une représentation des mécanismes de chiffrement : 

* Chiffrement Symétrique :

![Cles_symetriques.png](./imgs/Cles_symetriques.png)

Comme nous pouvons le constater Anne et Bob (aka Robert) ont tous les deux la clé de chiffrement donc peuvent chiffrer et déchiffrer les messages.

* Chiffrement Asymétrique :

![Assymetrie_-_signature_vs_chiffrement.png](./imgs/Assymetrie_-_signature_vs_chiffrement.png)

Dans l'image ci-dessus nous constatons que Anne est la seule à avoir la **clé Privé**, les autres intervenant n'ont en leur possession que la clé publique d'Anne. Deux opération sont réalisées dans le diagramme la première la signature de message , Anne envoie un message signé avec ça clé privé , grâce à la clé publique Bob et Dylan peuvent garantir que le message provient d'Anne. Le déchiffrement de la signature n'est possible qu'avec la pair associé à la clé publique donc la clé privé dont Anne est la seule propriétaire.
L'autre opération est le chiffrement d'information que Bob transmet à Anne , ce dernier chiffre l'information avec la clé publique d'Anne résultat uniquement la clé privé d'Anne est en mesure de déchiffrer le contenu. 

**ATTENTION** : prendre note que lors du chiffrement de message avec la clé privé tous le monde peut déchiffrer avec la clé publique distribué sur le net ! Donc si Anne désire transmettre un message chiffré à Bob, elle doit être avoir la clé publique de ce dernier.

Si nous revenons sur notre sujet, le système de certificat pour le site web , nous retrouvons cette pair de clé :

* Clé publique == Certificat 
* Clé privé == Clé privé installé sur le serveur


La clé n'est qu'une partie du Certificat, ce dernier est composé de plusieurs partie, il existe plusieurs type de certificat pour différent usage ( Certificat de courriel, d'authentification de machine , ... ). Dans le cadre de la configuration d'un serveur web nous utilisons les certificat [X.509](https://fr.wikipedia.org/wiki/X.509). 

Voici le contenu de la structure d'un certificat :

* Version
* Numéro de série
* Algorithme de signature du certificat
* DN (Distinguished Name) du délivreur (autorité de certification)
* Validité (dates limite)
*   Pas avant
*   Pas après
* DN de l'objet du certificat
* Informations sur la clé publique :
*   Algorithme de la clé publique
*   Clé publique proprement dite
* Identifiant unique du signataire (optionnel, X.509v2)
* Identifiant unique du détenteur du certificat (optionnel, X.509v2)
* Extensions (optionnel, à partir de X.509v3)
*   Liste des extensions
* Signature des informations ci-dessus par l'autorité de certification

À ce stade des explications je ne vais pas faire mention du **CA** (l'autorité de certification) gardons notre environnement autonome, mais pas de panique nous allons en parler :D.

Afin d'avoir un peu de concret je vous propose de faire la création d'un certificat **autonome** (self sign ou auto-signé), donc un certificat (clé publique) et une clé privé.

```bash

$ openssl req -x509 -newkey rsa:2048 -nodes -keyout server.key -out server.crt -days 365
Generating a 2048 bit RSA private key
................+++
....................................................................................+++
writing new private key to 'server.key'
 -----

You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
 -----

Country Name (2 letter code) [AU]:CA
State or Province Name (full name) [Some-State]:Quebec
Locality Name (eg, city) []:Montreal
Organization Name (eg, company) [Internet Widgits Pty Ltd]:X3rus
Organizational Unit Name (eg, section) []:Formation
Common Name (e.g. server FQDN or YOUR name) []:www.x3rus.com
Email Address []:

$ ls
server.crt  server.key

$ head -5 server.key server.crt 
==> server.key <==
 -----BEGIN PRIVATE KEY-----
MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDJsYXLGDBE8Zlh
4++b6bI0zDxonvPvuS/BI9M1wF7G2JPAhXHmBT7TpVfp3ekR7SuFIJVKEOn7xQiV
4kJwtnLexZDx3MaEJnBVsOcmz8dvyJ2eYif3p2WkGxbcyRRAV+KTXHSZgHdY6LfB
H08nBasY5nqJ5v27W2O/gC1RavsjAuHIPW7khcP2ksJEdbTsW1ihxp03NkA8xRX/

==> server.crt <==
 -----BEGIN CERTIFICATE-----
MIIDrTCCApWgAwIBAgIJAIM6pAb71wACMA0GCSqGSIb3DQEBCwUAMG0xCzAJBgNV
BAYTAkNBMQ8wDQYDVQQIDAZRdWViZWMxETAPBgNVBAcMCE1vbnRyZWFsMQ4wDAYD
VQQKDAVYM3J1czESMBAGA1UECwwJRm9ybWF0aW9uMRYwFAYDVQQDDA13d3cueDNy
dXMuY29tMB4XDTE2MDQwNTEyNDgyM1oXDTE3MDQwNTEyNDgyM1owbTELMAkGA1UE
```

Donc un peu d'explication pour bien saisir nous avons utilisé la commande **openssl** pour faire la génération d'un nouveau d'un certificat / clé privé de type **rsa** d'une taille de **2048 bits** le fichier de la clé privé est stocké dans le fichier __server.key__ alors que le certificat est contenu dans le fichier __server.crt__. Telle que mentionné dans la structure du certificat ce dernier doit avoir une date de validité , ici j'indique une validité de 365 jours à partir d'aujourd'hui **-days 365** .

Quand nous visualisons le fichier **server.crt** ce n'est pas très lisible , nous pouvons utilisons la commande **openssl** aussi pour afficher le contenu du certificat :

```bash
        $ openssl x509 -in server.crt -text
        Certificate:
            Data:
                Version: 3 (0x2)
                Serial Number:
                    83:3a:a4:06:fb:d7:00:02
            Signature Algorithm: sha256WithRSAEncryption
                 Issuer: C=CA, ST=Quebec, L=Montreal, O=X3rus, OU=Formation, CN=www.x3rus.com
                 Validity
                    Not Before: Apr  5 12:48:23 2016 GMT
                    Not After : Apr  5 12:48:23 2017 GMT
                 Subject: C=CA, ST=Quebec, L=Montreal, O=X3rus, OU=Formation, CN=www.x3rus.com
                 Subject Public Key Info:
                    Public Key Algorithm: rsaEncryption
                        Public-Key: (2048 bit)
                        Modulus:
                            00:c9:b1:85:cb:18:30:44:f1:99:61:e3:ef:9b:e9:
                            b2:34:cc:3c:68:9e:f3:ef:b9:2f:c1:23:d3:35:c0:
                            5e:c6:d8:93:c0:85:71:e6:05:3e:d3:a5:57:e9:dd:
                            e9:11:ed:2b:85:20:95:4a:10:e9:fb:c5:08:95:e2:
                            42:70:b6:72:de:c5:90:f1:dc:c6:84:26:70:55:b0:
           [ ... OUTPUT COUPÉ ... ]
             X509v3 extensions:
                X509v3 Subject Key Identifier:
                    0A:F2:CE:D0:5B:C1:84:F1:8F:AC:3B:73:FC:37:56:54:31:1F:C5:8F
                X509v3 Authority Key Identifier:
                    keyid:0A:F2:CE:D0:5B:C1:84:F1:8F:AC:3B:73:FC:37:56:54:31:1F:C5:8F
                X509v3 Basic Constraints:
                    CA:TRUE
                Signature Algorithm: sha256WithRSAEncryption
                    c5:08:1c:e0:d5:99:a4:44:e2:f0:41:ab:40:38:6b:fa:b9:00:
                    f9:6f:74:be:14:bc:4f:7f:c9:27:88:76:31:00:28:57:be:17:
           [ ... OUTPUT COUPÉ ... ]
```

Comme vous pouvez le constater à la lecture ci-dessus nous avons l'information sur du site web , nom du domaine , organisation , ... Ceci à la ligne **Subject:**, de plus nous avons la durée de validité du certificat disponible **Validity:**.

Un certificat n'est valide que pour un **FQDN** (__Fully Qualified domain name__) en d'autre mot que pour un nom de domaine complet le certificat ici présent est valide pour le domaine __www.x3rus.com__ mais n'est pas valide pour le domaine __x3rus.com__ . Il est possible de faire l'achat de certificat **wildcard** donc qui couvre l'ensemble des sous domaine d'un domaine (__\*.x3rus.com__) cependant le prix est significativement plus élevé.
Il existe aussi des certificats pour une liste de FQDN , ceci s'appuie sur le système de **SAN**, je ne couvrirai pas ici cette partie , je vous laisse un peu de chose à explorer :P.

Si nous mettons en place ce certificat, votre fureteur vous donnera une erreur lors de l'accès au site web mentionnant que ce dernier est auto signé. Ce qui veut dire que les communications seront chiffré, car il y a une clé publique (certificat) et une clé privé qui est disponible cependant l'authenticité du site web ne peut être validé.

Le système **httpS** offre aussi une garantie d'authenticité du site web avec qui nous communiquons. Pour permettre cette validation nous avons besoin d'un tierce qui va effectué cette validation, c'est à ce moment qu'arrive le **Certificat Authority** (__CA__) . C'est pour ce service que vous avez besoin d'acheter un certificat depuis un fournisseur, c'est uniquement pour que votre site soit certifié comme étant bien celui pour lequel il se présente. 

Vous vous demandez alors, mais alors qu'elle est la différence entre le certificat auto signé (__self Sign__) et celui fournit par un __CA__. Il n'y a qu'un légère différence , le système de clé publique et clé privé ne change pas , car le fournisseur de service ne doit JAMAIS avoir votre clé privé , il va uniquement apposer ça signature sur votre certificat.
Voici une représentation du certificat :

![representation_certificat.png](./imgs/representation_certificat.png)

La première partie correspond à la requête de certificat qui est transmise à l'autorité de certification ( __CA__ ), ceci comprend la clé public en relation avec la clé privé ainsi que l'information sur l'organisation. Ce n'est pas un certificat complet car il ne contient pas de date d'expiration ni d'émetteur (__issuer__). 
Quand l'on transmet la requête de certificat ce dernier ajouter les parties manquante , et signe le tous pour l'authentifier. 

Pour faire la création de la requête vous pouvez utiliser la commande :

```bash
        $ openssl req -new -newkey rsa:2048 -nodes -keyout server.key -out server.csr
        Generating a 2048 bit RSA private key
        .......................+++
        ......................................................+++
        writing new private key to 'server.key'
        -----
        You are about to be asked to enter information that will be incorporated
        into your certificate request.
        What you are about to enter is what is called a Distinguished Name or a DN.
        There are quite a few fields but you can leave some blank
        For some fields there will be a default value,
        If you enter '.', the field will be left blank.
        -----
        Country Name (2 letter code) [AU]:CA
        State or Province Name (full name) [Some-State]:Quebec
        Locality Name (eg, city) []:Montreal
        Organization Name (eg, company) [Internet Widgits Pty Ltd]:X3rus
        Organizational Unit Name (eg, section) []:formation
        Common Name (e.g. server FQDN or YOUR name) []:www.x3rus.com
        Email Address []:

        Please enter the following 'extra' attributes
        to be sent with your certificate request
        A challenge password []:
        An optional company name []:
```


Comme vous pouvez le constater quand nous avons créé un certificat auto signée et pour la requête nous avons fournit les mêmes informations. Une fois la requête crée généralement l'autorité de certification à un formulaire pour transmettre la requête puis vous recevez le certificat complet. La requête de certificat ne contenant pas de date peut être réutilisé lors de chaque renouvellement , CEPENDANT il est important de comprendre que la requête de certificat est aussi la clé publique donc vous devez conserver la même clé privé.


* Référence :

    * https://fr.wikipedia.org/wiki/Certificat_%C3%A9lectronique
    * https://fr.wikipedia.org/wiki/Infrastructure_%C3%A0_cl%C3%A9s_publiques

### Détail de la communication httpS

Maintenant que nous avons une meilleur compréhension du certificat nous allons voir le processus de communications lorsque le fureteur établie la connexion. Ceci nous permettra aussi de comprendre comment le certificat est valider avec l'autorité de certification. 

Une image vaut mille mot , voici donc 2 graphiques représentant la communication du processus de communication __SSL__. 

![SSLHandshake-v1.png](./imgs/SSLHandshake-v1.png)

![SSLHandshake-v2.gif](./imgs/SSLHandshake-v2.gif)


Si nous prenons la première image.

1. **TCP/IP** : Les flèches en bleu représente la connexion __TCP/IP__ la poignée de main ( __3 hand shake__ ) ceci représenté par les paquets (__SYN__, __SYN/ACK__, __ACK__). 

#### Processsus de négotiation des protocols supporté


1. **Client hello** : Le client transmet au serveur les protocoles __SSL/TLS__ qu'il supporte et désire utiliser pour la communication , de plus il fournit une liste de chiffrement supporté (__cipher suites__) pour la clé symétrique qui sera utilisé par la suite nous y reviendrons. Il y a aussi une numéro de session (session __ID__), ceci est un numéro aléatoire qui sera utilisé pour la génération des clés. Il peut y avoir d'autre information transmis.
2. **Server hello** : Le serveur reçoit la réponse du client et analyse s'il y a un match entre les protocoles __SSL/TLS__ supporté par le client et ceux qu'il supporte et en choisie un. Il réalise la même opération pour les chiffrements supportés (__cipher suites__). Lors de la réponse le serveur transmet sont certificats __SSL__ . Il y a aussi une numéro de session (session __ID__), ceci est un numéro aléatoire qui sera utilisé pour la génération des clés. Il peut y avoir d'autre information transmis.

#### Processus de validation du certificat

Lors de la réception du certificat le client valide ce dernier :

1. Validation de la date de validité , est-ce que le certificat est encore valide ? Ceci est réalisé récupérant l'information  : __Validity Not Before__ et __Validity Not After__
2. Par la suite le système valide que le certificat fut bien émis pour le site web indiqué, que l'URL concorde avec l'entrée __CN__ du certificat (__Subject: C=CA, ST=Quebec, L=Montreal, O=X3rus, OU=Formation, CN=www.x3rus.com__)
3. La client valide que le certificat fut signé / validé par une autorité de certificat (__verysign__,__godaddy__, __digicert__, ...) Pour ce faire il utilise les certificats (clé publique) présent sur le système ou dans le fureteur pour déchiffrer la signature réalisé par la clé privé du certificat d'autorité (__CA__). Lors de la description du certificat j'avais fait mention du processus de signature avec un certificat je vous invite a relire [cette section](#c_quoi_le_certificat). Vous pouvez voir dans votre fureteur la liste des certificats des __CA__ disponible :

![firefox_list_certificats.png](./imgs/firefox_list_certificats.png) 

4. Une fois que le certificat fut confirmé comme valide et émis par un fournisseur de certification, le système valide au près de cette autorité si le certificat présent ne fut pas révoqué. Il communique avec la __Certification Revocation List__ **CRL**, cette dernière est disponible comme information dans le certificat du __CA__

![firefox_digicert_crl.png](./imgs/firefox_digicert_crl.png)

Il existe aussi un autre protocole __OCSP__ qui permet d'avoir les certificats révoqué. L'objectif de ce mécanisme est que si pour une raison X votre système est compromis et quelqu'un vous vole la clé privé , vous êtes en mesure d'invalider le certificat pour que personne puisse l'utiliser. Cette opération doit être réalisé au près de votre autorité de certificat.

#### Échange d'une clé symétrique

Telle que mentionné plus tôt le système de clé asymétrique ne permet le chiffrement qu'avec le système de pair de clé, nous avons le certificat __SSL__ du serveur (clé publique) donc le client peut chiffrer les données qui ne seront décrypté que par le serveur. Le "problème" est que par défaut le client n'a PAS de certificat (ce est possible aussi certaine organisation utilise des certificats pour identifier les clients, cependant je conserve la cas classique telle que les communications avec une institue bancaire grand publique). De plus si le client avez un certificat afin d'assurer l'identité de ce dernier nous serions obligé de le renouveler régulièrement au près d'un __CA__.
Autre aspect négatif de l'utilisation d'un système de chiffrement par clé asymétrique telle que les certificats __SSL__ est le coût __CPU__ / mémoire requise pour chiffré et déchiffrer les communications. Ce système est beaucoup plus gourmand  en ressource. 

Donc pour contourner le problème de l'absence de certificat du client et pour améliorer les performances des communications __SSL__ un échange de clé symétrique est réalisé entre le client et le serveur. Le client génère un numéro aléatoire appelé **PRE-master key secret** qui est transmis au serveur. Afin d'assurer la confidentialité de cette clé , cette dernière est chiffré avec le certificat (clé public ) du serveur, ceci assure que uniquement le serveur sera en mesure de le lire.

Ceci est appelé **pre-master key** car le client ET le serveur réalise un calcule algorithmique afin de générer la clé de chiffrement final. Ce calcule génère la clé de chiffrement symétrique qui sera utilisé lors des communications entre le client et le serveur. La clé final n'est donc JAMAIS transmise sur le réseaux. 

Le client et le serveur transmette un message de fin de la négociation , validant ainsi le chiffrement , par la suite l'ensemble des communications sont chiffré avec la clé symétrique.

#### Représentation graphique détaillé du protocole SSL

Une représentation plus détaillé du protocole __SSL__ avec l'ensemble des clés et de nombre aléatoire généré.

![SSLHandshake-v3-two-way-auth.png](./imgs/SSLHandshake-v3-two-way-auth.png)

## Configuration simple d'un site web avec mod_ssl

Nous allons précéder à la mise en place d'une configuration très simpliste , ceci nous permettra avec l'ensemble des options de couvrir la théorie autour. 

Pour commencer nous allons activer le module **ssl** dans apache :

```bash
        $ cd /etc/apache2/mods-enabled
        $ sudo ln -s ../mods-available/ssl.load .
        $ sudo ln -s ../mods-available/socache_shmcb.load .
        $ sudo ln -s ../mods-available/ssl.conf .
        $ cat ssl.load  
        # Depends: setenvif mime socache_shmcb
        LoadModule ssl_module /usr/lib/apache2/modules/mod_ssl.so
```

Le fichier __ssl.conf__ contient des configurations par défaut, je vous laisse le plaisir de regarder le contenu , nous verrons certaines instruction par la suite.

Nous allons prendre le temps de réaliser la validation de la configuration suite à l'ajout des modules :

```bash
        $ sudo apachectl configtest
        Syntax OK
```

Si vous avez l'erreur suivante : 

```bash
        AH00526: Syntax error on line 43 of /etc/apache2/mods-enabled/ssl.conf:
        SSLSessionCache: 'shmcb' session cache not supported (known names: ). Maybe you need to load the appropriate socache module (mod_socache_shmcb?).
```

Ceci indique que vous n'avez pas créer le liens symbolique pour **socache\_shmcb.load** ce module est requis par **mod\_ssl** si vous lisez le fichier **ssl.load** c'est clairement indiqué :P.


Nous allons maintenant faire la création du site web pour __www.linux202-siteA.com__ aka __siteA__. Mais avant j'aimerai que l'on prenne une seconde pour voir le fichier **ports.conf**

```bash
        $ cat /etc/apache2/ports.conf
        Listen 80

        <IfModule ssl_module>
            Listen 443
        </IfModule>

        <IfModule mod_gnutls.c>
            Listen 443
        </IfModule>
```

Comme vous le savez peut-être et sinon je vais vous le dire , les communications en __http__ sont réalisées sur le port 80 alors que les communications chiffré sont réalisé sur le port 443. Si vous regardez le fichier __ports.conf__ nous pouvons voir que le port 443 sera ouvert si le module **ssl_module** est charger sinon il n'ouvre pas le port .

Ceci étant clarifier , pas de mystère nous pouvons procéder à la mise en place de la configuration pour le __siteA__ en **ssl**.

```
        $ sudo vim /etc/apache2/sites-available/siteA-ssl.conf
        $ cat /etc/apache2/sites-available/siteA-ssl.conf
        <VirtualHost 172.17.0.1:443>
            ServerAdmin webmaster@localhost
            ServerName www.linux202-siteA.com
            ServerAlias linux202-siteA.com
            ServerAlias toto.linux202-siteA.com
            
            DocumentRoot /data/vhosts/siteA/docroot/
            Alias "/cm-images" "/data/vhosts/common/images"

            <Directory /data/vhosts/siteA/docroot/>
                Options none
                AllowOverride ALL
                Require all granted
            </Directory>
            
            <Directory /data/vhosts/siteA/uploads/>
                Options none
                AllowOverride None
                Require all granted
            </Directory>
            
            # Configuration des logs
            ErrorLog /data/vhosts/siteA/logs/ssl_error.log
            CustomLog /data/vhosts/siteA/logs/ssl_access.log combined
            
            ## SSL section 
            SSLEngine on
            SSLCertificateFile "/etc/apache2/ssl/www_linux202-siteA_com.crt"
            SSLCertificateKeyFile "/etc/apache2/ssl/www_linux202-siteA_com.key"
        </VirtualHost>

```

Génération du certificat __SSL__ auto-signé , j'ai pas d'argent pour acheter un certificat pour la formation ;-), cependant bien que le certificat ne soit PAS valide le protocole __SSL__ est tous de même respecté. Le client utilisera le certificat pour transmettre les données chiffré au serveur pour la négotiation de la clé symétrique.

```bash
        $ cd ~
        $ mkdir ssl && cd ssl
        $ openssl req -x509 -newkey rsa:2048 -nodes -keyout www_linux202-siteA_com.key -out www_linux202-siteA_com.crt -days 365
        Generating a 2048 bit RSA private key
        ..............................................................................................................+++
        .................+++
        writing new private key to 'www_linux202-siteA_com.key'
        -----
        You are about to be asked to enter information that will be incorporated
        into your certificate request.
        What you are about to enter is what is called a Distinguished Name or a DN.
        There are quite a few fields but you can leave some blank
        For some fields there will be a default value,
        If you enter '.', the field will be left blank.
        -----
        Country Name (2 letter code) [AU]:CA
        State or Province Name (full name) [Some-State]:Quebec
        Locality Name (eg, city) []:Montreal
        Organization Name (eg, company) [Internet Widgits Pty Ltd]:X3rus
        Organizational Unit Name (eg, section) []:training
        Common Name (e.g. server FQDN or YOUR name) []: www.linux202-sitea.com
        Email Address []:
        $ sudo mkdir /etc/apache2/ssl
        $ sudo cp * /etc/apache2/ssl
```


Telle que mentionné plus tôt votre clé privé de chiffrement ET très très importante , car l'ensemble de la sécurité réside sur ce fichier. Il est très important de s'assurer de sécurisé ce dernier.

```bash
        $  ls -l /etc/apache2/ssl
        total 8
        -rw-r--r-- 1 root root 1334 Apr 20 08:36 www_linux202-siteA_com.crt
        -rw-r--r-- 1 root root 1704 Apr 20 08:36 www_linux202-siteA_com.key
        $ sudo chmod o-r /etc/apache2/ssl/www_linux202-siteA_com.key
```


Activation du serveur virtuel, validation de la configuration et redémarrage du service.

```bash
        $ cd /etc/apache/sites-enabled
        $ sudo ln -s ../sites-available/siteA-ssl.conf
        $ sudo apachectl configtest && sudo /etc/init.d/apache2 restart
        Syntax OK
         * Restarting web server apache2
         ...done.
```

Nous pouvons à présent accéder au site web __SSL__ avec notre fureteur: [https://www.linux202-sitea.com](https://www.linux202-sitea.com)

![sitea-ssl_untrusted_certificat.png](./imgs/sitea-ssl_untrusted_certificat.png)

Bien entendu comme nous n'avons pas un certificat signé par une autorité de certificat, nous avons ce message. **ATTENTION** il est important de bien prendre en considération se message et de ne pas accepter le certificat sans revalidé l'URL. Ce message ne devrais jamais s'affiché si vous communiquez avec un site "officiel".

Un fois le certificat accepté , le site nous est présenté :

![sitea-ssl.png](./imgs/sitea-ssl.png)


# Mais il est où le CA ?

Bon ok j'ai fait la démonstration de la configuration avec un certificat auto signé , malheureusement bien souvent c'est quoi le comportement ? Ça marche numéro 1 avec un __self-signe__ , mais le certificat n'est pas reconnue avec un certificat fournit par un CA. Bien entendu le problème n'est pas au niveau du fournisseur de service mais bien avec votre configuration. Donc nous allons couvrir la fonctionnalité d'un CA et la mise en place d'un certificat avec l'ensemble de la chaine. 

Alors là comme d'habitude je sais pas trop limiter mes formations :P , faut toujours que j'en fasse plus certain diront trop ... donc je vais le mettre la section suivante optionnel pour pas avoir un document trop gros. 
Comment comprendre quelque chose , le faire :D !!! C'est la meilleur manière de bien le comprendre avoir une réalité pratique de ce qui faut faire. Ça marche autant pour la mise en place d'une planché , une toilette , la céramique , ... Ceci est pareil pour l'informatique faut juste la documentation qui vient avec et une petite démonstration en plus ça l'aide :D. 
Donc le lien suivant c'est pour mettre en place une [Autorité de Certification CA](../setup-un-CA/01-introduction.md) , l'équivalent d'un digicert, very-sign, goDaddy , ... 

* [Autorité de Certification CA](../setup-un-CA/01-introduction.md)

Donc si ça ne vous motive pas passez direct à la prochaine section no stress :D.

## Mise en place d'un certificat reçu d'une tierce partie

Donc dans la présentation sur la mise en place d'une autorité de certification nous avons mis en place un CA , nous avons fait la création d'une requête de certificat , avec la commande suivante :

```bash
$ openssl req -new -newkey rsa:2048 -nodes -keyout toto.x3rus.com.key -out toto.x3rus.com.csr 
```

Le FQDN assigné fut **toto.x3rus.com** nous avons donc la clé privé **toto.x3rus.com.key** et transmis le fichier la demande de signature de certificat ( CSR - Certificat Signing Request) à l'autorité de certification. Nous avons reçu un fichier zip contenant 2 fichier :

* ca-chain.cert.pem
* toto.x3rus.com.cert.pem

Avec la clé nous avons l'ensemble requis pour faire la configuration.

* TODO :
    * Mise en place de la configuration sans la chaine de CA 
    * Erreur de certificat 
    * mise en place du ROOT CA dans les trustes toujours l'erreur
    * Mise en place de la chaine de certification dans la configue apache


# Communication entre 2 systèmes

## Problème de communication avec un service SSL 

Voyons le cas du déchiffrage d'une communication **SSL** , nous avons 2 produits disponible pour réaliser l'opération :

* [ssldump](http://ssldump.sourceforge.net/) : Personnellement je ne le connais pas , ce qui m'ennuie est que la dernière mise à jour date : 2013-04-17
* [wireshark](http://www.wireshark.org) : Logiciel que nous utilisons déjà pour capturer le trafic réseau de plus il est __multi-platforme__

__Wireshark__ est en mesure de déchiffré plusieurs protocole __SSL__ très bien , si votre service n'est pas présent ce ne veut pas dire que ça marchera pas mais il y a moins de garantie :

* 443 https
* 636 ldaps
* 989 ftps-data
* 990 ftps
* 992 telnets
* 993 imaps
* 994 ircs
* 995 pop3s
* 5061 sips 

Pour les besoins de la démonstration, je vais prendre le plus populaire soit __httpS__, voici un site web disponible :

**https//172.17.0.1/**

![site_demo_https.png](./imgs/site_demo_https.png)

Nous voyons qu'il y a le petit cadenas de présent , bon j'ai pas payé un certificat valide pour la formation , donc c'est un __self signe__

Nous pouvons utiliser la commande **openssl** , qui je crois est aussi disponible sous Windows ... Je vous laisse valider ce dernier point :P. 

Voici le résultat : 

```bash
        $ openssl s_client -connect 172.17.0.1:443
        CONNECTED(00000003)
        depth=0 C = CA, ST = Quebec, L = Montreal, O = X3rus, OU = training, CN = www.linux202-sitea.com
        verify error:num=18:self signed certificate
        verify return:1
        depth=0 C = CA, ST = Quebec, L = Montreal, O = X3rus, OU = training, CN = www.linux202-sitea.com
        verify return:1
        ---
        Certificate chain
         0 s:/C=CA/ST=Quebec/L=Montreal/O=X3rus/OU=training/CN=www.linux202-sitea.com
           i:/C=CA/ST=Quebec/L=Montreal/O=X3rus/OU=training/CN=www.linux202-sitea.com
           ---
           Server certificate
           -----BEGIN CERTIFICATE-----
           MIIDvTCCAqWgAwIBAgIJAPeQILfjif9uMA0GCSqGSIb3DQEBCwUAMHUxCzAJBgNV
           BAYTAkNBMQ8wDQYDVQQIDAZRdWViZWMxETAPBgNVBAcMCE1vbnRyZWFsMQ4wDAYD
           VQQKDAVYM3J1czERMA8GA1UECwwIdHJhaW5pbmcxHzAdBgNVBAMMFnd3dy5saW51
           eDIwMi1zaXRlYS5jb20wHhcNMTYwNDIwMTI0MDA4WhcNMTcwNDIwMTI0MDA4WjB1
           MQswCQYDVQQGEwJDQTEPMA0GA1UECAwGUXVlYmVjMREwDwYDVQQHDAhNb250cmVh
           bDEOMAwGA1UECgwFWDNydXMxETAPBgNVBAsMCHRyYWluaW5nMR8wHQYDVQQDDBZ3
           d3cubGludXgyMDItc2l0ZWEuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
           CgKCAQEA6U/3KzAdczpJ/zLWqYHFOkS0QnTY5u402mMvtyyUprSRC1hZbqYJakhn
           tkC/pvOni5BoAxXEPJCI84XQXbYq0mKH67GOq4Qu1VxEOuot+bIQ8qy92Srp/a9O
           uIwYa8cRwi5r/j6BgeXaN6yErtLJ5Ll+M7Aoamxs3gMcf4dZ3dc1t+evS8c5SAWg
           jLFnBNfLJrbKO4cPhwTHVARpwPGzRzBr8o/L1RmSnM3pr5wunsC258FOwJyBTrdk
           LXf7ggq4bd6eew+eW0GhTgykRH9ZgSaLY7/IeFnmggXqyoz3BJI9cMdfCVhUnKom
           wO1DAeVxKqiA++qm7Obbw9gxB2C/gwIDAQABo1AwTjAdBgNVHQ4EFgQUuEPXOcv7
           idBBIVrmexvpELETU78wHwYDVR0jBBgwFoAUuEPXOcv7idBBIVrmexvpELETU78w
           DAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAN5uY7FQrQNF1j7TyKrLl
           6WPu1+rsOADtNOKLoPANMRUvlhGkObjbVfzIyDOw7yUtEFsmEmTPkZ6jKbbDfS55
           Elf3kOFFICrZaxjQlkPpwEaMlommJCKDOsraDRYNGSLo7aSw2zSCEUZm0QluDtx2
           VnJ82drvlc8YcFVpOJLW89lHzczV3hHmyo6i7H1x/eSryBL/m08OPMar89iQnoHl
           T190I2xduWYFrGMuhYn3xpQVzxWJHhgDpwoK58zE9zaRdapt/P0kS+A8HgMw8qZP
           Wa0QrUtDqtc884lY2UsFKSweiTGoRmWOw0eRHyg1+q0+pPXTT/YvChKwFOsXlmds
           CA==
           -----END CERTIFICATE-----
```

Ceci me permet de récupérer le certificat (clé publique) du serveur et de confirmer que la communication fonctionne bien :P que le port 443 de l'IP 172.17.0.1 respecte bien le protocole __SSL__ car il m'a répondu avec le certificat :D.

Pour les personnes qui désire comprendre comment fonctionne protocole httpS je vous invite à consulter la vidéo que j'ai réalisé : [Comprendre httpS (certificat et échange avec le serveur)](https://www.youtube.com/watch?v=DilZTPJFVH4)

Pour les personnes qui veulent uniquement faire fonctionné __wireshark__ sans les explications allé voir l'URL suivante :
[jimshaver:decrypting tls browser traffic with wireshark the easy way](https://jimshaver.net/2015/02/11/decrypting-tls-browser-traffic-with-wireshark-the-easy-way/)

Vous êtes encore là ?? Alors on commence les autres passez à la prochaine section :D, y a pas de malaise :) !


### Déchiffrement de la communication avec un fureteur

Je vais commencer la démonstration du déchiffrement , c'est le chemin long, mais ce chemin à l'avantage de nous offrir l'ensemble de l'explication et de la connaissance. 
Je vais vous démontré les problèmes que j'ai eu lors de la préparation de cette formation , ceci m'a permit de vraiment mieux comprendre la partie théorique que j'avais réalisé sur le protocole **httpS**.

Premièrement j'ai récupérer la clé **privé** sur serveur web [www\_linux202-siteA\_com.key](https://raw.githubusercontent.com/x3rus/training/master/network/data/www_linux202-siteA_com.key). J'ai bien dit **privé** avec le certificat vous ne pouvez RIEN faire.

#### Tentative de déchiffrement avec uniquement la clé privé du SERVEUR

J'étais partie du principe que si j'avais la clé privé du serveur c'était bon j'étais en business !! Et bien non ! La démonstration suivant est **non fonctionnelle** , mais dans tous problème il y a quelque chose à apprendre .

Voyons comment j'ai réalisé la configuration de __wireshark__ :

* **Edit** __-->__ **preferences** 
* **protocole** __-->__ **HTTP** : j'ai valider que les ports que j'utilise est bien listé pour la section __SSL__
* **protocole** __-->__ **SSL** : 
    * __SSL debug file__ :  __/tmp/wireshark-ssl-debug.log__  (Ceci me permettra de visualiser les logs du traitement de __wireshark__
    * **RSA keys list** : 
    ![setup_wireshark_rsa_key.png](./imgs/setup_wireshark_rsa_key.png)

Voyons le résultat avec cette configuration : 

* Nous voyons le trafic dans __wireshark__ :
    * ![wireshark-tls-prob-cipher-1.png](./imgs/wireshark-tls-prob-cipher-1.png)
* Si nous essayons de déchiffrer le contenu **bouton droit de la souris** __-->__ **Follow SSL stream**:
    * ![wireshark-tls-prob-cipher-2-follow-stream.png](./imgs/wireshark-tls-prob-cipher-2-follow-stream.png) 

Humm mais pourquoi ?? Afin de répondre à cette question nous allons regarder le fichier __log__ de __wireshark__ (__/tmp/wireshark-ssl-debug.log__). Vous trouverez les informations suivante dans le fichier de __log__:

        dissect_ssl3_record: content_type 20 Change Cipher Spec
        ssl_load_keyfile dtls/ssl.keylog_file is not configured!
        ssl_finalize_decryption state = 0x17
        ssl_restore_master_key can't find master secret by Session ID
        ssl_restore_master_key can't find master secret by Session Ticket
        ssl_restore_master_key can't find master secret by Client Random

Cool , mais encore :P ? Effectivement nous avons la clé privé du serveur , mais le [cipher suite](https://fr.wikipedia.org/wiki/Suite_cryptographique) utilisé pour chiffré les données fait en sorte que nous n'avons pas les données . Un petit schéma / rappel du protocole __SSL__ :

![SSLHandshake-v1.png](./imgs/SSLHandshake-v1.png)

Ou nous avons aussi ce schéma :

![SSLHandshake-v2.gif](./imgs/SSLHandshake-v2.gif)

Donc si nous reprenons l'information du diagramme notre problème est que nous avons l'information pour déchiffré ce que le client Transmet au serveur , soit la **pre-master key** malheureusement une fois la négociation de la clé symétrique nous perdons l'information , car nous n'avons pas la **master key** clé symétrique de chiffrement qui fut calculé du coté client et serveur. 


#### Configuration du fureteur pour avoir la master key

Bon nous allons faire une modification de la configuration du fureteur afin d'être en mesure d'extraire la **Master key** qui fut échangé. Pour ce faire nous allons dire au fureteur d'écrire l'information dans un fichier texte qui sera fournit à __wireshake__

Sous GNU/Linux 

        $ export SSLKEYLOGFILE=/tmp/sslkeylog.log
        $ firefox 

Sous Windows et MAC : [https://jimshaver.net/2015/02/11/decrypting-tls-browser-traffic-with-wireshark-the-easy-way/](https://jimshaver.net/2015/02/11/decrypting-tls-browser-traffic-with-wireshark-the-easy-way/)

Je vais sur le site web __SSL__ : https://172.17.0.1

Voici un exemple du contenu du fichier :

        $ cat /tmp/sslkeylog.log
        # SSL/TLS secrets log file, generated by NSS
        CLIENT_RANDOM e643da0cbebfa8553022343817820b55e43efe30629b74bc0fb6f13f0d57668d 89472228100cd3c50140a787a72a618204780052afdc949b6f863a07eac23c68cc039b60239bfead812533e1d715ef5d
        CLIENT_RANDOM ded68bccc179cd17479d72ae7cf426df0e8d770844e21449cf425cb2994dce49 01feff746d34492a64fe06ea0d47d37497af3f06fda4d9df9d66ca93128e8fa0cbec1a456cfbb0ade712c183a2a79e9c
        CLIENT_RANDOM c33da9f992225b5b4e26ed7f017893755bc78d89b2c12e3ba5292a2f5d5dc9ec 89472228100cd3c50140a787a72a618204780052afdc949b6f863a07eac23c68cc039b60239bfead812533e1d715ef5d

Configurerons __wireshark__ pour qu'il lise ce fichier :

* **Edit** __-->__ **preferences** 
* **protocole** __-->__ **SSL** : 
    * __(Pre)master-secret log filename__ : __/tmp/sslkeylog.log__

![wireshark-ajout-master-key-file-pref-ssl.png](./imgs/wireshark-ajout-master-key-file-pref-ssl.png)


Nous referons un teste en accédant au site : __https://172.17.0.1__ 

![wireshark-fureteur-success-decrypt.png](./imgs/wireshark-fureteur-success-decrypt.png)

**WOWWW magic !!!!**


#### Méthode pour d'autre application

Bon c'est super cool, mais si je veux diagnostiquer avec une autre application que le fureteur je fais comment ?
Effectivement cette méthode est contraignante , voir très contraignante. Pour information la problématique est dans le type de __cipher__ qui est utilisé , [la suite cryptographique](https://fr.wikipedia.org/wiki/Suite_cryptographique) est le nom de la combinaison des algorithmes d'échange de clés, d'authentification, de chiffrement par bloc et génération du code d'authentification de message (MAC) utilisée afin d'établir le paramétrage de sécurité pour une connexion réseau utilisant le protocole de communication __Secure Socket Layer (SSL)__ et __Transport Layer Security (TLS)__. 

Si nous utilisons le **cipher** **Diffie-Hellman Ephemeral (DHE) ou RSA ephemeral cipher** , __wireshark__ n'est pas en mesure de réalisé le déchiffrement. Vous pouvez modifier probablement votre application afin de permettre l'écriture de la **master clé** mais ceci est très contraignant et ne représentera pas la réalité.

Le __cipher__ est négocié entre le client et le serveur, il est donc possible d'indiquer au serveur de ne PAS utiliser les __cipher__ problématique . Voici un exemple pour apache :

        # Configuration SSL
        SSLEngine on
        SSLCertificateFile "/etc/apache2/ssl/www_linux202-siteA_com.crt"
        SSLCertificateKeyFile "/etc/apache2/ssl/www_linux202-siteA_com.key"
        SSLCipherSuite RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

L'important ici est de désactiver le support __DHE__ par contre il a beaucoup de cipher qui l'utilise alors je spécifie ceux que je désire uniquement. **SSLCipherSuite**.

        $ sudo apachectl configtest && sudo /etc/init.d/apache2 restart

Maintenant coté client :

        $ unset SSLKEYLOGFILE
        $ echo $SSLKEYLOGFILE
        $ rm /tmp/sslkeylog.log
        $ firefox

Suppression configuration __wireshark__ pour qu'il ne lise plus le fichier :

* **Edit** __-->__ **preferences** 
* **protocole** __-->__ **SSL** : 
    * __(Pre)master-secret log filename__ : 


Donc je reprend avec __wireshark__ et je suis en mesure de déchiffrer le contenu , si ça vous intéresse vous pouvez voir le __cipher__ qui fut négocier dans les paquets :

* Le client propose les __ciphers__ suivant , dans le paquet **Client Hello** :
![cipher-client_hello.png](./imgs/cipher-client_hello.png)

* Le serveur répond avec le __cipher__ qu'il a choisit dans le paquet **Server Hello**:
[!cipher-server_hello.png](./imgs/cipher-server_hello.png)


Bien entendu cette méthode peut être impossible à mettre en place dans le cadre d'un serveur en production !! 
Donc prendre cette méthode avec un grain de sel et évaluer les conséquences de ce changement de configuration !

##### Configure application avec le bon cipher

Une fois le problème compris sur la source du problème de déchiffrement vous pouvez aussi modifier le comportement de l'application qui communique avec le serveur. Après tous la négociation du __cipher__ ce fait des 2 coté :P, je présente 2 options à vous de trouver le reste pour vos applications :

* __Firefox__ 
    * désactivation des __ciphers__ __DHE__ ET __ECDHE__ , allez dans la configuration **about:config** 
    * recherchez pour __dhe__ et désactivé le tous :
    ![firefox_dhe_disable.png](./imgs/firefox_dhe_disable.png)

    * ATTENTION il ne faut pas oublié une fois les testes réalisé de remettre la configuration convenablement au moins avant votre prochaine visite sur votre site bancaire :D.

* Java
    * la configuration de la __JVM__ est comme suit :  __jdk.TLS.disabledALGORITHMS=DHE, ECDHE__ honnêtement je ne l'ai pas tester :-/ , si une personne désire me fournir l'instruction exacte je suis preneur :D (à vos recherche , c'est l'occasion de participé à la formation ;-) )



#### Pour les guerriers  !! Vraiment optionnel !!

Bon petite mise en contexte, j'ai gagné (en savoir) / j'ai perdu (en temps) 5 trajet de train pour comprendre le tous !! Reprenons rapidement le schéma de la communication précédemment montré 

![SSLHandshake-v3-two-way-auth.png](./imgs/SSLHandshake-v3-two-way-auth.png)

Quand j'ai regardé le diagramme je me suis dit , **wowww** si on regarde bien les nombres aléatoire passe dans la communication :

* Le chiffre généré par le client (**RNc**)
* Le chiffre généré par le serveur (**RNs**)
* Ainsi que la **pré-master key** transmit par le client , chiffré avec le certificat du client

Alors je me suis dit , que si j'ai l'ensemble des 3 éléments , je vois pas pourquoi je ne suis pas en mesure de calculé MOI aussi comme un grand la **master key** :P . Après tous si Apache le fait , c'est libre donc il y a bien un bout de code à prendre quelque par pour extraire l'information !! 

Je suis donc partie d'une communication avec __firefox__ et le fichier de clé ou j'ai essayer de récupérer l'information . Si ça vous motive continué , mais je vous avise tous de suite , **ÇA FONCTIONNE PAS** :P . Je crois cependant que la connaissance est intéressante :D. 

Commençons par extraire l'information du fichier __ssllog__ que vous pourrez trouver sur __github__ ici : [ssl-log](https://raw.githubusercontent.com/x3rus/training/master/network/data/sslkeylog_firefox_https_dhe.log) 

        $ cat sslkeylog_firefox_https_dhe.log
        CLIENT_RANDOM eaba2ab12a4b3312da88a244beab1db493687d7946ff2583e6960d2d4d2ba9b6 04a1b54e353b28afcb64e1380d3c049a9662f53340b1fb91a0734287cd92327a0cb4da8d5bb3148b3873bd2fb00fd7e5
        CLIENT_RANDOM 4800c1d2126559f3e610ae217f0c5fa99a123a9a4f0232a7352f9a315ed6b9d7 a3f2325ff9f8606d33d4fd8ae2bf3e0f63ac7977e0829a494d1f88ed74173aa69455866c8b58ac714c84d950be3a130b
        CLIENT_RANDOM 187ed56c312cab9fce0a3540e06d3e427885ed3ed94b8338ba3ab53a3ffba855 04a1b54e353b28afcb64e1380d3c049a9662f53340b1fb91a0734287cd92327a0cb4da8d5bb3148b3873bd2fb00fd7e5

Vous trouverez aussi le fichier __wireshark__ de la communication sur __github__ ici : [wireshark-data](https://raw.githubusercontent.com/x3rus/training/master/network/data/firefox_https_with_dhe.pcapng) 

J'ai d'abord cherché le numéro aléatoire du client contenu dans la communication **client hello**, j'ai extrait les numéros voici la copie d'écran de l'opération :

![wireshark_get_first_random-client-num.png](./imgs/wireshark_get_first_random-client-num.png

Partie de l'heure IMPORTANTE :

![wireshark_get_first_random-client-num_second_part.png](./imgs/wireshark_get_first_random-client-num_second_part.png)

Si nous collons les 2 numéros ensemble ::

        eaba2ab12a4b3312da88a244beab1db493687d7946ff2583e6960d2d4d2ba9b6

**MAGIC** , alors là j'y est vraiment cru :P 

Passons à la partie du serveur , c'est aussi simple : 

![wireshark_get_first_random-server-num.png](./imgs/wireshark_get_first_random-server-num.png)

Bon c'est pas dans le fichier mais j'y croyais encore :P ...

Je suis passé à l'étape de chercher la **pre-master key**, c'est la que le problème commence !
L'échange de la __pre-master key__ est réalisé lors de la séquence **Client Key Exchange** :

![wireshark_get_preshare-key_client.png](./imgs/wireshark_get_preshare-key_client.png)

Si nous regardons nous constatons que ceci est une clé publique :-/ , donc ceci vient avec une clé privé, regardons un schéma  du protocole [Diffie-Hellman](https://en.wikipedia.org/wiki/Elliptic_curve_Diffie%E2%80%93Hellman).

![DH-diagramme-explication.png](./imgs/DH-diagramme-explication.png)

Le problème avec le __cipher__ Courbe Elliptique __Diffie Hellman__ (__ECDH__) est que nous n'avons pas de clé master qui est transféré mais uniquement la clé publique. Ceci est la raison pourquoi avec UNIQUEMENT le certificat du client nous ne sommes pas en mesure de déchiffré le contenu de la communication. Car le certificat n'est utilisé que lors de l'échange de clé , par la suite pour réduire la charge __CPU__ de déchiffrement une clé symétrique est échangé . C'est ce que l'on voit dans le diagramme juste avant le paragraphe.

Afin de visualisé l'échange lorsqu'il y a transfère de la __pre-master key__  j'ai refait la lecture de la communication avec le protocole __RSA__ "classique" comme indiqué plus tôt.

![wireshark-get_pre-master-key_RSA.png](./imgs/wireshark-get_pre-master-key_RSA.png)

Nous voyons clairement la clé présente , le calcule est donc possible pour avoir la **MASTER KEY**

Voilà j'espère que ça vous a permis de mieux comprendre comme moi l'ensemble du mécanisme :D.

* Référence 
    * [https://ask.wireshark.org/questions/34393/how-to-decrypt-ssl-traffic-using-wireshark](https://ask.wireshark.org/questions/34393/how-to-decrypt-ssl-traffic-using-wireshark)

    * [http://packetpushers.net/using-wireshark-to-decode-ssltls-packets/](http://packetpushers.net/using-wireshark-to-decode-ssltls-packets/)

    * https://wiki.wireshark.org/SSL
    * https://jimshaver.net/2015/02/11/decrypting-tls-browser-traffic-with-wireshark-the-easy-way/
    * http://support.citrix.com/article/CTX116557



## Visualisation d'une coupure de communication lors d'un transfert de paquet

Maintenant que nous avons identifié un problème de connexion qui ne fonctionne pas passons à un problème intermittent .
Ceci est le plus compliqué à identifier , je ne dis pas que j'ai la solution exacte, cependant vous permettra d'avoir un aperçu concret lorsque la situation ce produit. Chaque problème étant particulier à vous de l'adapter dans votre réalité .

Je vais utilisé le protocole SSH afin de faire la démonstration , j'ai une machine avec l'IP : __172.17.0.2__ qui a le service SSH présent nous allons faire un transfert de fichier avec __SCP__ pour le transfert.

* client : 172.17.42.1
* serveur : 172.17.0.2

Voici l'opération quand tous vas bien :

        $ scp bob@172.17.0.2:./usr-share-vim.tar /tmp/
        bob@172.17.0.2's password: 
        usr-share-vim.tar                              100%   25MB  25.2MB/s   00:01


Bon si nous regardons nous avons bien le __3 way handshake__ (__SYN , SYN/ACK, ACK__) , nous avons du transfert et la fin de connexion ( __FIN/ACK , ACK, FIN/ACK, ACK__). Si vous regardez attentivement vous constaterez qu'il y a aussi des messages étrange que nous n'avions encore jamais vu : **TCP Full Window** et **TCP ZeroWindows** , puis ils sont en noir et rouge , ça sonne PAS bon pourtant nous n'avons pas encore créer de __noise__ sur la ligne.

![transfert_scp_msg_windows_full.png](./imgs/transfert_scp_msg_windows_full.png)

Référence du problème __wireshark__ :  [https://ask.wireshark.org/questions/24501/why-would-tcp-full-window-happen](https://ask.wireshark.org/questions/24501/why-would-tcp-full-window-happen)

Premièrement ce n'est PAS une erreur ceci est simplement un avertissement , si vous avez le message **TCP Full Window** et que vous avez après **TCP ZeroWindows** il n'y a PAS de problème. Ok cool mais POURQUOI ?

Regardons cette nouvelle copie d'écran :

![transfert_scp_msg_windows_full_2.png](./imgs/transfert_scp_msg_windows_full_2.png)

Afin d'optimiser le transfert __TCP__ entre le client et le serveur négocie un nombre de paquet (__windows size__) qui peut être transféré entre le client et le serveur sans que le client soit obligé de confirmer la réception. 

Voici un exemple :

* Le client (récepteur) ssh avise qu'il va prendre une fenêtre TCP de 5000 bytes
* Le serveur (émetteur) envoie 5 paquets TCP d'une longueurs de 1000 chaque
* Il n'y a AUCUN accusé de réception des paquets pour ces 5 .
* __Wireshark__ mark le 5ieme paquet avec l'identifiant __TCP WINDOWS FULL__ afin d'indiquer qu'il n'y a pas eu de __ACK__ pour ces dernier.

Le client à 3 possibilités :

* Transmettre le message __\[Zero Windows\]__ : indiquant que son __buffer__ est plein et d'attendre que ce dernier est fini de traiter les données
* Transmettre le message __\[TCP Window Update\]__ : indiquant qu'il traite encore des données mais que ça fenêtre est un peu libre donc que le serveur peut remplir N bytes
* Transmettre le __ACK__ : Afin d'indiquer au serveur que l'on peut reprendre le transfert .


Maintenant que nous avons vu le comportement quand tous va "bien" malgré les messages d'avertissement de __wireshark__ sur la question de la fenêtre de transmission reprenons l'opération. Cette fois ci, je vais faire le transfert mais en plein milieu je vais bloquer la communication avec une règle de __firewall__ afin de simuler une coupure de connexion. La coupure sera temporaire quelques secondes afin de voir le comportement quand la communication reprend.
La règle de __firewall__ fut mis en place pour coupé les communications sur le port 22 du __client__ **vers** le __serveur__.

Voici le résultat à l'écran:

        $ scp bob@172.17.0.2:./usr-share-vim.tar /tmp/
        bob@172.17.0.2's password:
        usr-share-vim.tar                                           35% 9088KB   2.8MB/s - stalled -
        [... COUPURE PUIS la reprise ...]
        usr-share-vim.tar                                           100%   25MB  25.2MB/s   00:01

Si nous regardons le résultat au niveau de __wireshark__ :

![transfert_scp_bloque_with_iptables.png](./imgs/transfert_scp_bloque_with_iptables.png)

C'est partie :D :D , le plaisir commence :D , pour bien comprendre le mécanisme de récupération et retransmission il faut ce concentré sur les numéros de séquence des paquets (**seq**) qui permet de suivre le numéro de chaque paquet , ainsi que les confirmation de réception (**ACK**) qui sont en relation avec séquence de transmission. Un petit rattrapage sur la théorie, car j'avais mis de coté cette aspect dans l'attente d'avoir un exemple concret.
Avec __wireshark__ vous pouvez visualiser la séquence d'échange **seq** et **ack** , pour ce faire ouvrez un fichier de trace et sélectionnez dans le menu **statistics --> Flow graph**.

Voici un exemple de résultat:

![tcp_flow.png](./imgs/tcp_flow.png)

* Client : 192.168.1.2
* Serveur : 174.143.213.18

Voici une petite explication quand tous fonctionne bien ;-) :

1. Établissement de connexion
    1. Client : **Syn** (__seq=0,ack=94856056__) , le premier paquet , le numéro de __ack__ est aléatoire dans ce cas il sera réinitialisé à zéro par la suite une fois le dialogue établie.
    2. Serveur : **Syn,Ack** (__seq=0,ack=1__) Le client débute ça séquence aussi à 0, mais la valeur de __ack__ est à 1 , lors de la présence d'un **SYN** ou **FIN** le numéro de **ACK** est incrémenté.
    3. Client : **Ack** (__seq=1,ack=1__) Le client transmet le **ack** de fin d'établissement de connexion , il prend la valeur du __ACK__ reçu et l'assigne au numéro de séquence.
2. Transfert de donnée du client vers le serveur 
    * Client : **Psh,Ack len(725)** (__seq=1,ack=1__) Le client transfert un paquet d'une longueur de 725 au serveur
3. Réponse du serveur des données reçu
    * Serveur : **ACK** (__seq=1,ack=726__) , le serveur confirme la réception du paquet précédent , lors du __ack__ il incrément la valeur **1** original de son coté et l'incrément de la longueur du dernier paquet reçu soit **725** . Résultat lors de ça réponse la valeur de __ack__ est (1+725=726). C'est comme si le serveur répondais j'ai bien reçu un paquet de 725.
4. Transfert du serveur vers le client
    * Serveur : **ACK len(1448)** (__seq=1,ack=726__), le serveur transmet un paquet __ack__ d'une taille de 1448. 
5. Réponse du client après la réception des données du serveur
    * Client : **ACK** (__seq=726,ack=1449__), donc de la séquence du client à augmenté représentant la quantité de données déjà transmisse. Tous comme le serveur il incrémente la valeur de __ack__ avec la quantité de donnée reçu du serveur
6. Serveur retransmet des données
    * Serveur : **ACK len(1448)** (__seq=1449,ack=726__) le serveur retransmet un paquet de 1448, le numéro de séquence est 1449 car le serveur n'a transmit pour le moment qu'un paquet de 1448 + 1 , le numéro de confirmation (__ack__) correspond à 1 + 725 (quantité de donnée transmise par le client)
7. Le client confirme la réception
    * Client : **ACK** (__seq=726,ack=2897__) , le client à transmit un paquet paquet d'une taille de 1 + 725 donc sont numéro de séquence n'augmente PAS, uniquement le numéro de confirmation __ack__ qui représente (1+1448+1448).
8. Etc jusque la fin de la connexion :P...

Référence : [http://packetlife.net/blog/2010/jun/7/understanding-tcp-sequence-acknowledgment-numbers/](http://packetlife.net/blog/2010/jun/7/understanding-tcp-sequence-acknowledgment-numbers/)

Bon après se long texte quand tous va bien maintenant on revient à notre problème :P :

* \#1583 : Le client transmet __ACK__ pour confirmer la réception du transfert (malheureusement la règle de __firewall__ bloque la transmission vers serveur, mais le client ne le sais pas encore) (__seq=5046, Ack=9337176__)
* \#1584 : Le client transmet un paquet chiffré au serveur ( mais ce dernier ne le recevra PAS à cause du __firewall__) (__seq=5046, Ack=9337176__)
* \#1585 : Le serveur transmet un paquet car lui n'a aucun problème de communication avec le client (__seq=9337176,Ack=5046__)
* \#1586 : Le client transmet un paquet chiffré toujours (__seq=5082,ack=9338624__)
* \#1587 : Le client transmet un autre paquet chiffré (__seq=5118,ack=9338624__)
* \#1588 : Le client retransmet le dernier paquet(__seq=5118,ack=9338624__), pourquoi ? Car il à attendu un certain temps mais le serveur n'a pas continuer à retransmettre des paquets. Si vous regarder la colonne __time__ le chiffre est significativement plus haut que lors du transfert régulier de paquet. Bien entendu ce paquet n'arrivera JAMAIS au serveur
* \#1589 : Le client transmet un paquet , car comme nous avons activé le mode __drop__ dans le __firewall__ le client croit que le paquet est arrivé RIEN ne lui indique qu'il y a eu un problème il doit attendre la confirmation de réception du serveur ou l'absence de confirmation pour savoir qu'il y a eu un problème (__seq=5154,ack=9338624__)
* \#1590 : Le client transmet un paquet car il croit que les 2 derniers furent reçu (__seq=5190,ack=9338624__)
* \#1591 : Le serveur ne recevant pas d'accusé de réception refait l'envoie : (__seq=9261396,ack=5046__)
* \#1592 : Le client à reçu la demande du serveur , car la communication n'est pas bloqué dans ce sens il renvoie donc le __ACK__ en fait il dit qu'il a de la disponibilité dans la fenêtre __TCP__ (__seq=5226,ack=9338624__)
* \#1593 : Le client retransmet  (__seq=5046,ack=9338624__)
* \#1594 : Le serveur retransmet le paquet **#1591** (__seq=9261396,ack=5046__)
* \#1595 : Le client retransmet le paquet **#1592** (__seq=5226,ack=9338624__)
* \#1596 : Le client retransmet le paquet (__seq=5046,ack=9338624__)
* \#1597 : Le serveur retransmet le paquet **#1578** (__seq=9261396,ack=5046__)
* \#1598 : Le client retransmet un autre __ACK__ équivalent au paquet **#1595** et **#1592** (__seq=5226,ack=9338624__)
* \#1599 : Le client retransmet le paquet **#1596**(__seq=5046,ack=9338624__)
* \#1600 : Le serveur renvoie le paquet **#1594** ou **#1591**(__seq=9261396,ack=5046__)

Le jeu va continuer comme ça jusqu'au moment ou le __timeout__ de communication sera atteint et que le serveur coupe la communication, car il ne reçoit plus d'information du client.


