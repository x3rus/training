
# Opération simple avec EC2 

Je n'aurais pas la prétention de dire que nous allons voir l'ensemble des possibilités avec __EC2__ , le nombre de possibilité est tellement grande et mon expérience trop mince pour couvrir l'ensemble des possibilités !!

Je vais comme toujours faire de mon mieux, en respectant mes intérêts :P , nous verrons par la suite où ceci nous mène . 
Pour débuter nous allons :

* comprendre un peu mieux les aspects **Réseau et sécurité** , l'objectif est de voir comment assurer l'accès aux instances __EC2__ via le système de clé ssh, donc le contrôle d'accès. Par la suite nous verrons comment faire communiquer les instances entre elle, en comprenant la limitation des accès réseaux en place. À ce stade nous ne verrons pas la gestion des réseaux, j'espère le voir plus tard.

## Réseau et sécurité

Nous allons voir les bases de la configuration pour notre instance __EC2__, pour ceux qui ont déjà eu la chance de jouer avec __AWS__ ceci sera peut-être connu , bien que je pense qu'il a toujours des clarifications à extraire d'une formation.

* Compréhension de l'utilisation des clés ssh.
* Contrôle d'accès au instance.
* Communication réseau entre les instances .

Référence : [Network and Security](http://docs.aws.amazon.com/fr_fr/AWSEC2/latest/UserGuide/EC2_Network_and_Security.html)

### Clé de connexion ssh

Lors de la démonstration de la création de l'instance __EC2__ nous avons créer une clé SSH pour être en mesure d'établir une connexion sur la machine. Cette clé __ssh__ fut assigné à l'utilisateur __ec2-user__. Nous l'avions généré à la volé avec l'interface d'Amazon, pour rappel la clé __SSH__ se divise en 2 partie : 

* Clé privé : Cette dernière est critique pour la sécurité de la communication, en fait l'ensemble de la sécurité est basé sur le fait que cette clé n'est pas compromise. Lors de la génération par Amazon, la clé fut téléchargé et telle que mentionné par le service il ne fallait pas la perdre , car aucune copie n'est conservé chez Amazon. Si nous perdons la clé nous ne serons plus en mesure d'établir de connexion sur notre instance, à moins d'assigner une nouvelle paire de clé . Nous le verrons plus tard...
* Clé publique : Cette dernière est installé sous l'utilisateur, dans notre cas __ec2-user__ et elle est associé à la clé privé. Comme son nom l'indique elle est publique non critique au niveau sécurité.

Si vous voulez plus d'information sur le système __SSH__ et les clés privées je vous invite à consulter le site de formation : [X3rus moodle ssh](http://moodle.x3rus.com/mod/lesson/view.php?id=89&pageid=29)

Je voulais clarifier ce point afin de mettre tous le monde au même niveau.
Bien entendu le fait que l'ensemble de la sécurité est basé sur la clé privée et que cette dernière est généré sur un environnement que l'on ne contrôle pas c'est pas super . Nous verrons un peu plus tard comment générer ou installé NOTRE clé ssh afin qu'elle ne soit pas généré sur les systèmes d'Amazon. Mais avant d'en arriver là nous prendrons la vois de la simplicité en utilisant leur système.

* Particularité Amazon et le système de clé
    * Les clés utilisées par Amazon sont des clés **RSA SSH-2 2048 bits**.
    * Vous pouvez définir jusqu'à **5000 paires de clés par région**.
    * Chaque pair de clé doit avoir un nom.
    * Uniquement la clé publique est conservé chez Amazon.

#### Création d'une clé ssh avec AWS

Comme nous l'avons déjà vu , nous pouvons faire la création d'une nouvelle clé directement lors de la création d'une instance, cependant si nous automatisons la création via un script se sera compliquer de réaliser en plus la création de la clé.

Il est donc possible de pré générer la clé de connexion , voici les étapes.

1. Ouvrez la console d'Amazon __EC2__  [https://console.aws.amazon.com/ec2/](https://console.aws.amazon.com/ec2/) et sélectionnez **Key Pairs**

    ![](./imgs/creation-key-pairs-01.png)
2. Vous aurez la liste des clés présente dans la région , pour rappel chaque région est "indépendante", mais interconnecter. 

    ![](./imgs/creation-key-pairs-02-view.png)
3. Cliquez sur le bouton de création d'un pair de clé **Creation Key Pair** et assigné lui un nom adéquat !!

    ![](./imgs/creation-key-pairs-03-creation.png)
4. Une fois l'opération réalisé , le système vous offrira de télécharger la clé 

    ![](./imgs/creation-key-pairs-04-download.png)


#### Suppression d'une clé 

On va tous de suite couvrir cette partie. 

1. Ouvrez la console d'Amazon __EC2__  [https://console.aws.amazon.com/ec2/](https://console.aws.amazon.com/ec2/) et sélectionnez **Key Pairs**

    ![](./imgs/creation-key-pairs-01.png)
2. Vous aurez la liste des clés présente dans la région , pour rappel chaque région est "indépendante", mais interconnecter. 

    ![](./imgs/creation-key-pairs-02-view.png)
3. Clique droit ou sélectionnez la clé et faire **delete**


Conséquence ?? 

* Vous ne pourrez plus assigné cette clé aux nouvelle instances, bien entendu si vous avez réalisé une copie de la clé publique préalablement vous pourrez remettre cette clé disponible dans __AWS__.
* L'ensemble des instances qui ont actuellement la clé de configurons ne seront PAS impacté par la suppression.
* Par contre , si vous utilisez un système __d'auto scaling__ qui démarre des instances automatiquement lors de la monté en charge sur un service , ces dernières ne pourront plus être instancié !!

#### Importation d'une clé ssh avec AWS

Telle que mentionné, il est aussi possible d'importer une clé ssh dans votre compte Amazon dans la région sélectionné ! 
Bien entendu il est faut préalablement générer la paire de clé ( publique et privé ) , voici les étapes bien entendu sous GNU/Linux pour les utilisateur d'un autre système __google is your friend :P__ .

* Génération de la clé 

1. Nous utiliserons la commande **ssh-keygen** :

```bash
$ ssh-keygen -t rsa -b 2048
Generating public/private rsa key pair.
Enter file in which to save the key (/home/VotreUtilisateur/.ssh/id_rsa): /home/VotreUtilisateur/.ssh/aws_training    
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/VotreUtilisateur/.ssh/aws_training.
Your public key has been saved in /home/VotreUtilisateur/.ssh/aws_training.pub.
The key fingerprint is:
SHA256:GnJiBmhwW07rr0mcXuqGWtmBmRUrv5cjR/+enp4D4ug VotreUtilisateur@hostname
The key's randomart image is:
+---[RSA 2048]----+
|. . +            |
|.o = +           |
|..+ =            |
|.  X             |
|  + O + S        |
|   * X.=.        |
|  o.BoO...       |
| ..ooO.. ..+     |
|.. +E    +O.     |
+----[SHA256]-----+

```
2. Ceci aura généré 2 fichier sous le répertoire $HOME/.ssh/ , le fichier .pub est la clé **publique** et le fichier sans extension la clé privé.

```bash
 $ ls -ltr /home/VotreUtilisateur/.ssh/
 total 28
 -rw-r--r-- 1 VotreUtilisateur VotreUtilisateur   33 Sep 27  2016 config
 -rw-r--r-- 1 VotreUtilisateur VotreUtilisateur 9710 Mar 27 15:04 known_hosts
 -rw-r--r-- 1 VotreUtilisateur VotreUtilisateur  394 Apr 20 08:36 aws_training.pub
 -rw------- 1 VotreUtilisateur VotreUtilisateur 1766 Apr 20 08:36 aws_training
```
3. Voici le contenu de la clé publique : 

```bash
$ cat /home/VotreUtilisateur/.ssh/aws_training.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8cVFsE0eyLzkm6d6hc8bEqgVPmitFeWhR5fd7bX+/D2nkY25E3qngJUdYi3gsp9JV5Sb9W5jhIJbhs5+OAhblenLauYkdyVATMT7epQzHt3j79+77N+0cV/WNFK9F5Fw+eCLutfHWJdLRn+eVDZoybg4SaPEMKy34SoCzC9wMUByisDcoZbH823/pk7m5DtkmkveWmjAHiUgV7a4U8f3Rl/oWKaMM40Xi/rNECI03oHyS4iuCDNs6b8Ix1vx8et9oddklYP1UedQuixJlkejflk38u98mfejiuy498nmclkehwiuyf3nr3h98ujpocxaoieu98ehfkjnoi32joic5 VotreUtilisateur@hostname
```

Maintenant que nous avons la clé publique nous allons pouvoir l'importer dans __AWS__.


1. Ouvrez la console d'Amazon __EC2__  [https://console.aws.amazon.com/ec2/](https://console.aws.amazon.com/ec2/) et sélectionnez **Key Pairs**

2. Sélectionnez **import key pair**

![](./imgs/import-key-pairs-01-view.png)
3. Entrez le nom de la clé et copier coller le contenu du fichier __.pub__

![](./imgs/import-key-pairs-02-import.png)

Et voilà pas plus compliquer que ça !!

#### Perte de la clé (oupsss )

![](./imgs/emoticon-cry-small.jpg){ align=right }

Dans la cas de la perte de la clé privé, si vous n'avez pas d'autre utilisateur que celle par défaut __d'EC2__ vous ne serez plus en mesure d'établir une connexion à l'instance. Bien entendu ceci est critique, donc assurez vous de conserver la clé dans un lieu pris en sauvegarde, et sécurisé je vous suggère fortement d'utiliser un système de gestion de mot de passe qui est en mesure de prendre en charge les fichiers.

Bon si la catastrophe est déjà arrivé vous faites quoi ? 

Si votre instance comme stockage des disques __EBS__, vous pourrez éteindre votre instance et assigné le disque dur que l'instance problématique à une nouvelle instance démarrer . Par la suite vous aurez la libertés de changer les configurations ssh pour reprendre la main dessus . 
Voici le lien explicatif d'Amazon , j'espère avoir le temps de faire une démonstration plus tard , je l'ai mis dans la liste des choses à couvrir.

Référence Amazon : http://docs.aws.amazon.com/fr_fr/AWSEC2/latest/UserGuide/ec2-key-pairs.html#replacing-lost-key-pair

### Pare-feu ou Groupes de sécurité 

Amazon nomme le son pare-feu **Groupe de sécurité** , ce dernier est donc un __firewall__ logiciel qui peut être modifier lors de l'utilisation de l'instance . L'avantage du système se trouve dans le mot __groupe__ :P , en fait il est possible d'ajouter plusieurs groupe à une instance ceci permet donc de faire des type de configuration ou ... __groupe__ :P  qui pourront s'appliquer à plusieurs instance utilisant la même définition .

La mise en place d'un groupe de sécurité est obligatoire lors du démarrage d'une instances __EC2__ , même si vous laissé l'ensemble ouvert ! Comme toujours les groupe de sécurité sont restreint par région ! Lors qu'une instance utilise un groupe de sécurité vous ne pouvez pas le modifier ( renommer , supprimer, ...) par contre il est possible de modifier le contenu des règles ( ajout ou suppression ).
Le changement sera pris en considération est automatiquement appliqué au instance qui sont associés au groupe de sécurité.

Vous pouvez définir jusqu'à 500 groupes de sécurités par région !! Chaque groupe de sécurité peuvent contenir jusqu'à 100 règles. 

#### Particularité des groupes de sécurité

* **Trafic sortant** 
    * L'ensemble du trafic sortant est permis par défaut
    * Pour les groupes de sécurité __EC2 classic__ vous ne pouvez pas modifier les règles pour le trafic sortant , vous devrez définir un réseau __VPC__
* **Trafic entrant**
    * Vous ne pouvez définir que des règles permissives, il n'y a pas d'option pour définir une règle qui bloque
    * L'ensemble des règles sont géré avec l'état ( __states full__  ) , si vous envoyez une demande à partir de votre instance, le trafic de la réponse à cette demande est autorisé, indépendamment des règles entrantes des groupes de sécurité. Pour les groupes de sécurité VPC, cela signifie aussi que les réponses au trafic entrant autorisé ont le droit d'être acheminées vers l'extérieur, indépendamment des règles sortantes.
* **Général** 
    * Il est possible de modifier à tous moment les règles ces dernières s'appliqueront à l'ensemble des instances utilisant le groupe de sécurité. Il y a bien entendu une brève période avant l'application réelle le temps de propagation de la configuration !
    * Il est possible d'assigner plusieurs groupe de sécurité à une instances , ces groupes formeront un tous. Ceci peut être particulièrement intéressant de regrouper vos règles selon les rôles de la machines. 

Une règle est composé de : 

* **Protocole** : Par exemple __TCP__ , __UDP__ ou __ICMP__ les protocoles les plus courant.
* **Port** : Pour les protocoles __TCP__ ou __UDP__ vous pouvez définir un port ou un range de port en utilisant la notation 1000-1500 
* **ICMP code et type** : Pour le protocole __ICMP__ vous pouvez définir le type et le code
* **Source et Destination** : Bien entendu il est possible de définir la source et / ou la destination en spécifiant une adresse IP spécifique ( 66.23.18.23/32) ainsi que des segments réseaux plus large ( 82.23.23.43/29)  est composé de : 
*
* * **Protocole** : Par exemple __TCP__ , __UDP__ ou __ICMP__ les protocoles les plus courant.
* **Port** : Pour les protocoles __TCP__ ou __UDP__ vous pouvez définir un port ou un range de port en utilisant la notation 1000-1500 
* **ICMP code et type** : Pour le protocole __ICMP__ vous pouvez définir le type et le code
* **Source et Destination** : Bien entendu il est possible de définir la source et / ou la destination en spécifiant une adresse IP spécifique ( 66.23.18.23/32) ainsi que des segments réseaux plus large ( 82.23.23.43/29)  est composé de : 
*
* * **Protocole** : Par exemple __TCP__ , __UDP__ ou __ICMP__ les protocoles les plus courant.
* **Port** : Pour les protocoles __TCP__ ou __UDP__ vous pouvez définir un port ou un range de port en utilisant la notation 1000-1500 
* **ICMP code et type** : Pour le protocole __ICMP__ vous pouvez définir le type et le code
* **Source et Destination** : Bien entendu il est possible de définir la source et / ou la destination en spécifiant une adresse IP spécifique ( 66.23.18.23/32) ainsi que des segments réseaux plus large ( 82.23.23.43/29). Un point intéressant vous pouvez spécifier un autre groupe de sécurité :
    * __EC2-Classic__ : un groupe de sécurité différent pour __EC2-Classic__ dans la même région.
    * __EC2-Classic__ : un groupe de sécurité pour un autre compte __AWS__ de la même région (ajoutez __l'ID__ de compte __AWS__ comme préfixe ; par exemple, __111122223333/sg-edcd9784__).

#### Création d'un groupe de sécurité

Voici un exemple de création d'un groupe de sécurité :

1. Ouvrez la console d'Amazon __EC2__  [https://console.aws.amazon.com/ec2/](https://console.aws.amazon.com/ec2/) et sélectionnez **Security Groups**

![](./imgs/groupe-securite-01-view.png)
2. Définir le nom du groupe , vous pouvez l'associer à un __VPC__ , le nom bien que arbitraire je vous encourage à mettre quelque chose de bien .

![](./imgs/groupe-securite-02-creation-01.png)
3. Définition des ports et réseau permit pour le trafic entrant

![](./imgs/groupe-securite-03-creation-02.png)
4. Définition des ports et réseau pour le trafic sortant

![](./imgs/groupe-securite-04-creation-03.png)

Et voilà on peut dire que Amazon nous facilite beaucoup la vie :D.

#### Démonstration communication entre 2 instance EC2

Maintenant que nous avons visualiser ce qu'est le système de pare feu sous Amazon je pense qu'une petite démonstration s'impose pour que lorsque vous désirerez mettre en place la solution vous soyez en mesure de comprendre où ça peut loquer.

Voici la situation j'ai démarrer 2 instances __EC2__ et nous allons nous s'assurer que nous sommes en mesure de communiquer entre elle, vous pouvez vous imaginez que ceci est le serveur web et une base de donnée . J'ai utilisé 2 instance de type **t2.nano** car je n'ai pas besoin de performance, mais uniquement de la __stack__ IP pour valider la communication.

Note : J'ai du prendre une image Linux Amazon, car le type RedHat 7 n'est pas possible pour le système **t2.nano** , c vraie qu'il n'y a pas beaucoup de CPU ni mémoire ... Bon encore une fois m'en fou un peu car je veux juste le __kernel__ et la carte réseau.

* Visualisation des 2 instances : 

![](./imgs/demo-aws-2-ec2-network-comm-01.png)

* Établissement de connexion sur chaque instance et visualisation de l'état 

```bash
$ ssh -i aws_training ec2-user@ec2-52-15-233-165.us-east-2.compute.amazonaws.com

        __|  __|_  )
        _|  (     /   Amazon Linux AMI
        ___|\___|___|

https://aws.amazon.com/amazon-linux-ami/2017.03-release-notes/
2 package(s) needed for security, out of 2 available
Run "sudo yum update" to apply all updates.
[ec2-user@ip-172-31-46-78 ~]$
[ec2-user@ip-172-31-46-78 ~]$ hostname
ip-172-31-46-78
[ec2-user@ip-172-31-46-78 ~]$ cat /proc/cpuinfo | grep name
model name      : Intel(R) Xeon(R) CPU E5-2676 v3 @ 2.40GHz
[ec2-user@ip-172-31-46-78 ~]$ ip addr show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 0a:67:07:39:7f:dd brd ff:ff:ff:ff:ff:ff
    inet 172.31.46.78/20 brd 172.31.47.255 scope global eth0
[ec2-user@ip-172-31-46-78 ~]$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.31.32.1     0.0.0.0         UG    0      0        0 eth0
169.254.169.254 0.0.0.0         255.255.255.255 UH    0      0        0 eth0
172.31.32.0     0.0.0.0         255.255.240.0   U     0      0        0 eth0
```

```bash

       __|  __|_  )
       _|  (     /   Amazon Linux AMI
       ___|\___|___|

https://aws.amazon.com/amazon-linux-ami/2017.03-release-notes/
2 package(s) needed for security, out of 2 available
Run "sudo yum update" to apply all updates.
[ec2-user@ip-172-31-33-230 ~]$ hostname
ip-172-31-33-230
[ec2-user@ip-172-31-33-230 ~]$ cat /proc/cpuinfo | grep name
model name      : Intel(R) Xeon(R) CPU E5-2676 v3 @ 2.40GHz
[ec2-user@ip-172-31-33-230 ~]$ ip addr show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 0a:d9:3e:f0:f1:d5 brd ff:ff:ff:ff:ff:ff
    inet 172.31.33.230/20 brd 172.31.47.255 scope global eth0
[ec2-user@ip-172-31-33-230 ~]$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.31.32.1     0.0.0.0         UG    0      0        0 eth0
169.254.169.254 0.0.0.0         255.255.255.255 UH    0      0        0 eth0
172.31.32.0     0.0.0.0         255.255.240.0   U     0      0        0 eth0
```

Donc nous avons :

* __ip-172-31-33-230__ , avec l'IP 172.31.33.230/20 
* __ip-172-31-46-78__ , avec l'IP 172.31.46.78/20

Juste pour être certain que tous le monde soit sur la même longueur d'onde les 2 machines SONT sur le MÊME réseau, si vous avez besoin :

```bash
$ ipcalc 172.31.33.230/20
Address:   172.31.33.230        10101100.00011111.0010 0001.11100110
Netmask:   255.255.240.0 = 20   11111111.11111111.1111 0000.00000000
Wildcard:  0.0.15.255           00000000.00000000.0000 1111.11111111
=>
Network:   172.31.32.0/20       10101100.00011111.0010 0000.00000000
HostMin:   172.31.32.1          10101100.00011111.0010 0000.00000001
HostMax:   172.31.47.254        10101100.00011111.0010 1111.11111110
Broadcast: 172.31.47.255        10101100.00011111.0010 1111.11111111
Hosts/Net: 4094                  Class B, Private Internet
```

J'installe __telnet__ sur les 2 instances  , car je suis vieux puis j'aime bien :

```bash
[ec2-user@ip-172-31-46-78 ~]$ sudo yum install telnet
[ec2-user@ip-172-31-33-230 ~]$ sudo yum install telnet

```

Si j'essaye depuis la première instance de communiquer avec la seconde sur le port 22 , PAS de problème :D 

```bash
[ec2-user@ip-172-31-46-78 ~]$ telnet 172.31.33.230 22
Trying 172.31.33.230...
Connected to 172.31.33.230.
Escape character is '^]'.
SSH-2.0-OpenSSH_6.6.1
^]
telnet> q
Connection closed.

```

Teste de connexion interne à l'instance 172-31-33-230 , pour valider que l'ensemble fonctionne avant d'essayer entre les instances.

```bash
[ec2-user@ip-172-31-33-230 ~]$ nc -l 2222
[ WAIT ... ] 

[ec2-user@ip-172-31-33-230 ~]$ sudo netstat -lntp | grep 2222
tcp        0      0 0.0.0.0:2222                0.0.0.0:*                   LISTEN      2707/nc

[ec2-user@ip-172-31-33-230 ~]$ telnet 172.31.33.230 2222                                                                                                      
Trying 172.31.33.230...
Connected to 172.31.33.230.
Escape character is '^]'.
TOTO
communication LOCAL
^]
telnet> q
Connection closed.

``` 

Résultat sur l'autre terminal  :

```bash
[ec2-user@ip-172-31-33-230 ~]$ nc -l 2222
TOTO
communication LOCAL
[ec2-user@ip-172-31-33-230 ~]$
```

Maintenant depuis l'autre serveur :

```bash
[ec2-user@ip-172-31-33-230 ~]$ nc -l 2222
[ WAIT ... ]

[ec2-user@ip-172-31-33-230 ~]$ sudo netstat -lntp | grep 2222                                                                                                 
tcp        0      0 0.0.0.0:2222                0.0.0.0:*                   LISTEN      2715/nc
```

Tentative de connexion : 

```bash
[ec2-user@ip-172-31-46-78 ~]$ telnet 172.31.33.230 2222
Trying 172.31.33.230...
telnet: connect to address 172.31.33.230: Connection timed out
```

Visualisation des règles de pare-feu :

![](./imgs/demo-aws-2-ec2-network-comm-02-firewall.png)

Ajout de la règles requise uniquement pour le segment réseaux :

![](/.imgs/demo-aws-2-ec2-network-comm-03-firewall-add.png)

Validation du comportement après l'ajout :

```bash
[ec2-user@ip-172-31-46-78 ~]$ telnet 172.31.33.230 2222
Trying 172.31.33.230...
Connected to 172.31.33.230.
Escape character is '^]'.
MALADE
Juste le temps de changer de fenetre
^]
telnet> q
Connection closed.
[ec2-user@ip-172-31-46-78 ~]$


[ec2-user@ip-172-31-33-230 ~]$ nc -l 2222
MALADE
Juste le temps de changer de fenetre

```

### Organisation de votre réseau chez Amazon (VPC)

Pour la démonstration réalisé ci-dessus nous avons vu le système de groupe de sécurité, en d'autre mot le système de pare feu inclus avec les __EC2__. Nous allons maintenant continuer avec la réseautique des instances __EC2__, nous allons voir le concept de **VPC** **Amazon Virtual Private Cloud (Amazon VPC)**. 

Une description simple du __VPC__ est un réseau virtuel privé qui vous ai dédié , il est possible de le segmenté en sous réseau, un peu comme lors que nous segmentons le réseau interne d'une entreprise. Lors de l'initialisation de nos instances __EC2__ ces dernières étaient déjà dans un __VPC__ . Si nous regardons la description de nos instances :

![](./imgs/demo-aws-2-ec2-network-comm-01-plus-vpc.png)

Ce __VPC__ fut créé automatiquement et par défaut l'ensemble des instances __EC2__ que nous allons créer seront dans ce __VPC__ . 

En fait il y a 2 type de réseaux :

* __EC2-classic__
* __VPC__ 

Je ne couvrirai PAS le réseau __EC2-classic__, car voici la liste des instances qui doivent être obligatoirement instanciées dans un __VPC__ : 

* __C4__
* __I3__
* __M4__
* __P2__
* __R4__
* __T2__
* __X1__

Comme vous pouvez le constater ceci est l'ensemble des instances, donc par soucis d'économie d'effort je vais me concentrer sur le __VPC__ par contre si vous désirez approfondir l'aspect __EC2-classic__ et au moins comprendre la différence avec les __VPC__ , je vous invite à consulter cette page : [http://docs.aws.amazon.com/fr\_fr/AWSEC2/latest/UserGuide/using-vpc.html#differences-ec2-classic-vpc](http://docs.aws.amazon.com/fr_fr/AWSEC2/latest/UserGuide/using-vpc.html#differences-ec2-classic-vpc) . Cependant prendre note que les comptes créés après le 04-12-2013 prennent uniquement en charge __EC2-VPC__ !

Comme l'aspect des coûts est critique clarifions une chose tous de suite : Il n'y a **AUCUN COÛT** pour ce service !! Le coût est pour ce que vous mettez dans le __VPC__ en d'autre mot les instances __EC2__, le balancer de charge , ... 
Vous aurez un coût si votre __VPC__ est connecter avec un __VPN__ , mais ceci est en dehors du cadre (__scope__) ici. 

J'avais fait mention en __PCI__ lors de la présentation du cloud , les __VPC__ sont conforme aux normes __PCI__ [lien](http://docs.aws.amazon.com/fr_fr/AmazonVPC/latest/UserGuide/VPC_Introduction.html#pci-compliance).

Que pouvons nous mettre dans un __VPC__ en d'autre mot dans notre réseau dédié chez Amazon ? 

| Service                | Rubrique correspondante                          |
|------------------------|--------------------------------------------------|
| AWS Data Pipeline      | [Launching Resources for Your Pipeline into a VPC](http://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-resources-vpc.html) |
| Amazon EC2             | [Amazon EC2 and Amazon VPC](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-vpc.html) |
| Auto Scaling           | [Auto Scaling and Amazon VPC](http://docs.aws.amazon.com/autoscaling/latest/userguide/autoscalingsubnets.html)|
| Elastic Beanstalk      | [Using AWS Elastic Beanstalk with Amazon VPC](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/AWSHowTo-vpc.html) |
| Elastic Load Balancing | [Setting Up Elastic Load Balancing](http://docs.aws.amazon.com/elasticloadbalancing/latest/userguide/setting-up-elb.html) |
| Amazon ElastiCache     | [Using ElastiCache with Amazon VPC](http://docs.aws.amazon.com/AmazonElastiCache/latest/UserGuide/ManagingVPC.html)|
| Amazon EMR             | [Select a Subnet for the Cluster](http://docs.aws.amazon.com/emr/latest/DeveloperGuide/emr-plan-vpc-subnet.html)|
| AWS OpsWorks           | [Running a Stack in a VPC](http://docs.aws.amazon.com/opsworks/latest/userguide/workingstacks-vpc.html) |
| Amazon RDS             | [Amazon RDS and Amazon VPC](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.RDSVPC.html) |
| Amazon Redshift        | [Managing Clusters in a VPC](http://docs.aws.amazon.com/redshift/latest/mgmt/managing-clusters-vpc.html) |
| Amazon Route 53        | [Working with Private Hosted Zones](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-private.html) |
| Amazon WorkSpaces      | [Create and Configure Your VPC](http://docs.aws.amazon.com/workspaces/latest/adminguide/gsg_create_vpc.html) |

#### Comprendre le __VPC__ 

Pour les besoins de l'explication je vais utiliser la configuration actuelle avec laquelle nous avons travailler pour détailler le tous , pour ceux que ça intéresse moins vous pouvez toujours consulter la documentation sur Amazon . [Concept du VPC](http://docs.aws.amazon.com/fr_fr/AmazonVPC/latest/UserGuide/VPC_Introduction.html#Overview).

Nous allons visualiser le __VPC__ actuel , nous allons donc sélectionner le service __VPC__ dans la liste des produits disponible dans Amazon 

![](./imgs/vpc-documentation-01-select-service.png)

Nous aurons la visualisation du / des __VPC__ disponible :

![](./imgs/vpc-documentation-02-view-activ-vpc.png)

Donc notre __VPC__ à une plage d'adresse IP : 172.31.0.0/16 

```bash
$ ipcalc 172.31.0.0/16
Address:   172.31.0.0           10101100.00011111. 00000000.00000000
Netmask:   255.255.0.0 = 16     11111111.11111111. 00000000.00000000
Wildcard:  0.0.255.255          00000000.00000000. 11111111.11111111
=>
Network:   172.31.0.0/16        10101100.00011111. 00000000.00000000
HostMin:   172.31.0.1           10101100.00011111. 00000000.00000001
HostMax:   172.31.255.254       10101100.00011111. 11111111.11111110
Broadcast: 172.31.255.255       10101100.00011111. 11111111.11111111
Hosts/Net: 65534                 Class B, Private Internet
```

Nous pouvons donc avoir jusque 65532 machines dans se segment réseaux , si on le remplie ça fera plein d'argent ($$$) pour Amazon :P. 

Bon pour ceux qui pensent, __ouin__ y commence à me perdre avec ces segments réseaux , j'ai un cours sur le réseau aussi :P, mais on va essayer de faire sans ...

Reprenons notre testes réalisé un peu plus tôt entre les 2 instances pour la communications réseau et l'ouverture des ports . 

Nous avions 2 machines :

* 172.31.46.78/20
* 172.31.33.230/20 

Ces 2 machines  avec comme route par défaut : 172.31.32.1/32

Analysons les adresses IP avec le segment réseau :

* Segment réseau du __VPC__ : 172.31.0.0/16
* Segment réseau des 2 machines que nous avons instancié : 172.31.32.0/20 ( machine 172.31.46.78/20, 172.31.33.230/20)

        ```bash
        $ ipcalc 172.31.46.78/20
        Address:   172.31.46.78         10101100.00011111.0010 1110.01001110
        Netmask:   255.255.240.0 = 20   11111111.11111111.1111 0000.00000000
        Wildcard:  0.0.15.255           00000000.00000000.0000 1111.11111111
        =>
        Network:   172.31.32.0/20       10101100.00011111.0010 0000.00000000
        HostMin:   172.31.32.1          10101100.00011111.0010 0000.00000001
        HostMax:   172.31.47.254        10101100.00011111.0010 1111.11111110
        Broadcast: 172.31.47.255        10101100.00011111.0010 1111.11111111
        Hosts/Net: 4094                  Class B, Private Internet
        ```
* Représentation graphique de la situation

        ![](./imgs/VPC_schema-01.png)

Comme vous pouvez le constater le segment réseau où évolue nos instances Amazon que nous avons démarrer est plus petit que celle qui nous est alloué . 172.31.32.0/20 est plus petit que 172.31.0.0/16 . Pourquoi ? Comment expliquer cette situation , pour le moment ceci n'est pas critique, car nous sommes loin de 4094 instances, par contre nous devons comprendre cette situation.

Nos 2 instances définie évolue dans 1 sous-réseaux distinct , qui fut créé automatiquement par Amazon lors de l'initialisation des instances ! Reprenons le schéma présenté plus haut en ajoutant cette réalité de sous-réseau.

![](./imgs/VPC_schema-02.png)

Lors de la visualisation de l'instance nous pouvons voir clairement le sous-réseau (__subnet__) :

![](./imgs/demo-aws-2-ec2-network-comm-01-plus-vpc.png)

Nous pouvons voir l'ensemble des sous réseaux créer en allant dans l'interface de gestion __d'AWS__ . 

![](./imgs/vpc-documentation-03-view-subnet-vpc.png)

Comme vous pouvez le voir il y a 3 sous-réseaux présent , bien que je n'ai JAMAIS définie manuellement de sous-réseau pour mes instances l'ensemble fut réalisé automatiquement par Amazon, bien entendu le but est de me "sécurisé" :P.


##### Comprendre les sous-réseaux __VPC__ 

Donc les sous-réseaux permette de réaliser une segmentation réseau de votre __VPC__chez Amazon, pour les personnes réalisant pas mal de réseau le concept est évidant pour les autres je vais prendre quelques minutes pour développer .

L'objectif ici est de segmenter les machines selon leur rôles afin de limiter les possibilités de communication , l'objectif principale est de faire en sorte que si une machines est compromise cette dernière ne pourra pas être utilisé pour compromettre les autres !

Prenons 2 applications "classique" développé en mode 3 tiers :

* Service frontal, répondant au requête des clients  : Apache ou __Ngnix__ 
* Service applicatif, réalisant l'ensemble des traitements (__processing power__) : __Tomcat__ ou application python
* Service de stockage de donnée (__backend__) : __Mysql__ ou __postgesql__ 

Voici une représentation d'une segmentation possible de l'infrastructure :

![](./imgs/VPC_schema-03-3-tiers.png)

Donc nous avons 3 sous réseau dans le même __VPC__ :

* Frontal : 172.31.32.1/24 : comprenant 2 machines Apache et Ngnix avec comme passerelle par défaut 172.31.32.1.
* Applicatif : 172.31.33.1/24 : comprenant 2 machines App01 et App06 comme passerelle par défaut 172.31.33.1.
* BD : 172.31.34.1/24 : comprenant 2 machines BD01 et BD41 avec comme passerelle par défaut 172.31.34.1.

Comme nous pouvons le voir chaque sous-réseau à ses règles de pare feu qui permet de limité les communications avec le restes des réseaux , nous avons donc 3 pare feu pour les __subnet__ . Ceci vous permet de limiter l'accès pour l'ensemble de la "zone" . Ceci permet de gérer à plus haut niveau pour un regroupement de machine. 
Bien entendu l'objectif est de limiter l'accès aux machine , dans l'exemple ci-dessus si une machines dans le réseau **frontal** est compromise , l'attaquant  ne sera pas en mesure d'établir une connexion **ssh** vers le serveur applicatif !

Les groupes de sécurité (pare feu au niveau instance EC2) est toujours présent si vous désirez réalisé de la gestion granulaire par instance ! 
Pour finir vous avez aussi un pare feu (__firewall__) pour l'ensemble des communications qui sort du __VPC__.

Je sais ceci fait beaucoup de __firewall__ à différent niveau , bien entendu il n'est pas obligatoire de les activer tous , par exemple par défaut les règles définie dans le __firewall__ du __VPC__ sont ouvert au complet . Réalisons une liste des __firewalls__ du plus spécifique au plus général.

1. __sécurity group__ : __firewall__ de la machine / instance __EC2__
2. __firewall__ du sous-réseau : __firewall__ appliqué à un regroupement de machines / instances 
3. __firewal__ du __VPC__ : __firewall__ du regroupement de sous réseau.


Selon votre niveau de maturité et bien entendu de vos besoins il est possible de créer d'autre __VPC__ qui regrouperont d'autre __sous-réseaux__ honnêtement pour le moment je ne vois pas le requis ... Cependant je voulais le signaler.

Si vous voulez vous compliquer la vie , rien ne vous empêche d'ajouter un __firewall__ sur la machine avec **iptables** ou **nf** , bon après trop de pare feu ne facilite pas l'analyse lors de problématique. 

##### Possibilité avec le__VPC__ 

Le système __VPC__ vous offre les fonctionnalités suivante

* Attribuer des adresses IPv4 privées statiques à vos instances qui persistent lors des démarrages et des arrêts.
  Si vous avez jouez avec Amazon vous avez constatez que les IP assignées au instances change à chaque démarrage, bien entendu vous pouvez définir des adresses IP fixe. Ceci peut être pratique pour plusieurs service __DNS__ , __NTP__, ... Cependant si votre objectif est de mettre en place une solution **Cloud**, donc qui peut grandir selon les besoins , faite attention au restriction d'adresses IP . Le système de découvert __discovery__ système est plus approprié.
  ICI ICI ICI Ajouter des description par point 



* Vous pouvez aussi associer un bloc d'adresse CIDR IPv6 à votre VPC et attribuer des adresses IPv6 à vos instances
* Attribuer des adresses IP multiples à vos instances
* Définir des interfaces réseau et attacher une ou plusieurs interfaces réseau à vos instances
* Changer les membres d'un groupe de sécurité pour vos instances pendant qu'elles s'exécutent
* Contrôler le trafic sortant de vos instances (filtrage sortant) ainsi que le trafic entrant vers vos instances (filtrage entrant)
* Ajouter une couche de contrôle d'accès supplémentaire à vos instances sous la forme de listes de contrôle d'accès (ACL) réseau
* Exécuter vos instances sur un matériel à client unique

#### Limite de déploiement de __vpc__ 

http://docs.aws.amazon.com/fr_fr/AmazonVPC/latest/UserGuide/VPC_Appendix_Limits.html
http://docs.aws.amazon.com/fr_fr/AmazonVPC/latest/UserGuide/VPC_Introduction.html#CurrentCapabilities


