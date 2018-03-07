# Configuration réseau

Dans cette section nous allons principalement traiter du protocole TCP/IP , si vous désirez configurer un autre type de réseau il faudra consulter la documentation approprié. Nous allons voir la configuration pour Debian/Ubuntu et Redhat/CentOS ceci couvre les deux famille les plus populaires. Comme nous utilisons Ubuntu je vais commencer par Redhat ce sera fait et nous pourrons nous concentrer sur notre distribution. Oui encore une fois quelque différence bien que minime elles sont présente.

La configuration réseau comprend:

* Le __hostname__ (nom machine)
* La définition d'une adresse ip
* La définition d'un netmask (masque réseau)
* La définition du gateway (passerelle réseau)
* La définition des DNS
* Nomenclature des cartes réseaux sous GNU/Linux :

## Comprendre les termes et concept réseau propre à Linux

Commençons par un peu de lexique afin de bien ce comprendre sur le choix des terme, de plus ceci vous permettra de mieux saisir la documentation disponible sur Internet. 

* **Device** : le périphérique physique, ceci peut être un carte réseau ethernet comme nous avons l'habitude d'utiliser ou tout autre périphérique réseau. 
* **Interface** : l'interface est ce qui est utilisé par le système d'exploitation pour communiquer avec le device. Ceci est donc la partie logiciel qui fait la transition entre l'ensemble du système avec le côté physique.  Comme nous l'avions vu cette opération est réalisé par le kernel, l'interface est donc le résultat de l'opération réalisé par le driver / pilote /module du kernel. 
	GNU/Linux utilise la nomenclature suivante pour nommer les interfaces : eth0, eth1, eth2,....
		* La première carte réseau (device) est associée a l'interface eth0 (eth0 utilisable par le système)
		* La deuxième carte réseau (devise) est associée à l'interface eth1 (eth1 utilisable par le système )
		* Etc , vous avez compris le principe. 
* En plus des interfaces eth* , il existe l'interface lo, ceci fait référence a un device virtuel qui est le localhost (127.0.0.1). Cette interface permet de réaliser des connexions réseau local sans utiliser l'interface externe.

## Visualisation de la configuration réseau

Il existe 2 commande pour visualiser la configuration TCP/IP du système .
**ifconfig** et **ip**.
Je vous invite fortement à concentrer vos efforts sur la commande **ip** , à terme ceci sera la seule commande disponible . Linux est en cours de transition vers la nouvelle commande, certaines distribution n'offre plus **ifconfig**.

### Utilisation de ifconfig

Telle que mentionné cette commande va disparaître cependant vous la retrouverez encore dans beaucoup de documentation il est donc intéressant de la connaître.  Nous nous concentrons actuellement uniquement à la visualisation , il est possible d'assigner des adresses ip avec la commande ipconfig. Si vous utilisez cette méthode sachez que lors du prochain reboot la configuration sera perdu , cette pratique n'est donc pas recommandé sauf pour un test. Il est toujours pertinent de visualiser le man page !

**ipconfig** nous permet de visualiser:

* l'adresse ip
* le masque réseau
* l'adresse broadcast
* les mac adresse ipV4, ipV6
* Le nombres de packets transmis et reçu
* La quantité de donnée transféré

Voici un exemple d'utilisation de **ifconfig**:

```bash
admuser@srv01:~$ /sbin/ifconfig 
eth0      Link encap:Ethernet  HWaddr 08:00:27:e8:c1:19  
          inet addr:10.0.2.15  Bcast:10.0.2.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fee8:c119/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:68 errors:0 dropped:0 overruns:0 frame:0
          TX packets:62 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:10319 (10.3 KB)  TX bytes:7793 (7.7 KB)
 
lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
 
 
 # ou avec argument:
admuser@srv01:~$ /sbin/ifconfig  eth0
eth0      Link encap:Ethernet  HWaddr 08:00:27:e8:c1:19  
          inet addr:10.0.2.15  Bcast:10.0.2.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fee8:c119/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:105 errors:0 dropped:0 overruns:0 frame:0
          TX packets:88 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:13001 (13.0 KB)  TX bytes:11293 (11.2 KB)
```

### Utilisation de route / netstat -r

la commande route nous permet de voir le routage réseau configurer sur la machine , en plus de la commande route la commande **netstat** est aussi utilisable avec l'option **-r** :

```bash
 # utilisation de route
admuser@srv01:~$ route 
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         10.0.2.2        0.0.0.0         UG    100    0        0 eth0
10.0.2.0        *               255.255.255.0   U     0      0        0 eth0
 
 # utilisation de netstat
admuser@srv01:~$ netstat  -r
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
default         10.0.2.2        0.0.0.0         UG        0 0          0 eth0
10.0.2.0        *               255.255.255.0   U         0 0          0 eth0
```

Comme vous pouvez le constater vous pouvez voir la route par défault avec l'interface de sortie, je ne ferai pas une explication du routage ici , ce n'est pas dans le scope de la formation.

### Connaître l'état de l'interface (mii-tool)

Nous avons listé l'adresse **ip** et la table de routage , nous avons vu aussi avec **ifconfig** qu'il est possible de voir la quantité de données transféré mais aucun information sur le mode de communication de l'interface , somme nous en 10 __half-duplex__ ? , 100 __full-duplex__ ? Pour répondre à cette question il est possible d'utiliser la commande **mii-tool** , cette commande peut aussi manipuler l'interface pour changer cette configuration.

```bash
 # comme simple utilisateur 
admuser@srv01:~$ mii-tool eth0
SIOCGMIIPHY on 'eth0' failed: Operation not permitted
 
 # evidament il faut être root pour réaliser l'opération
admuser@srv01:~$ sudo mii-tool eth0
[sudo] password for admuser: 
eth0: no autonegotiation, 1000baseT-FD flow-control, link ok
```

### Visualisation du hostname

La commande hostname permet d'afficher .... oui oui le hostname de la machine :D , n'est-ce pas fabuleux ?

```bash
admuser@srv01:~$ hostname
srv01
```

### Visualisation des DNS configurer

La configuration des DNS se fait dans le fichier **/etc/resolv.conf** ce fichier comprend la liste des DNS utilisable , lors de la tentative de résolution le système prend le premier , si ce dernier ne répond pas il prendra le suivant , etc. Il est possible de définir un domaine de recherche pour que par exemple si je tape uniquement __srvLdap__ , il essaye d'ajouter le nom de domaine fournit par exemple __x3rus.com__. Voici un exemple du fichier de configuration :

```bash
admuser@srv01:~$ cat /etc/resolv.conf 
nameserver 8.8.8.8
nameserver 8.8.4.4
search x3rus.com
```

### Visualisation de la configuration avec la commande ip

Telle que mentionné l'application **ip** sera a terme celle disponible pour l'ensemble de la configuration , cette commande est déjà disponible sur l'ensemble des systèmes. Nous allons donc voir cette commande.

Visualisation de l'adresse **ip** avec **ip** , la commande est simple **ip addr show**:

```bash
admuser@srv01:~$ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 08:00:27:e8:c1:19 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fee8:c119/64 scope link
       valid_lft forever preferred_lft forever
 
 # uniquement une interface
admuser@srv01:~$ ip addr show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 08:00:27:e8:c1:19 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fee8:c119/64 scope link
       valid_lft forever preferred_lft forever
```

Nous retrouvons l'information de l'adresse ip ainsi que la mac adresse de l'interface, encore une fois nous avons l'interface eth0 et lo , il est possible d'extraire l'information d'une seul interface.

Visualisation des **routes**:

```bash
admuser@srv01:~$ ip route show
default via 10.0.2.2 dev eth0  metric 100 
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
```

Le contenu est claire , nous voyons la route par défaut ainsi que la route pour le réseau à proximité sur eth0.

Il est possible d'avoir de l'information sur les packets reçu et transféré:

```bash
admuser@srv01:~$ ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 08:00:27:e8:c1:19 brd ff:ff:ff:ff:ff:ff
 
admuser@srv01:~$ ip -s link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    RX: bytes  packets  errors  dropped overrun mcast   
    0          0        0       0       0       0      
    TX: bytes  packets  errors  dropped carrier collsns 
    0          0        0       0       0       0      
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 08:00:27:e8:c1:19 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast   
    8574220    8824     0       0       0       0      
    TX: bytes  packets  errors  dropped carrier collsns 
    404681     3628     0       0       0       0  
```

## Configuration de l'ip temporaire.

Configuration de l'adresse ip mais sans utilise les fichier de configuration, ceci aura l'avantage de vous permettre de faire des testes de configuration sans altérer la configuration, cependant n'oubliez pas de modifier les fichiers de configuration une fois la configuration adéquatement définie.

```bash
 # configuration ancienne méthode 
admuser@srv01:~$  sudo ifconfig eth0 10.0.2.17 netmask 255.255.255.0 
admuser@srv01:~$  sudo route add default gw 10.0.2.2
 
 # configuration avec ip
admuser@srv01:~$  sudo /sbin/ip addr add 10.0.2.17/24 dev eth0
admuser@srv01:~$  sudo /sbin/ip route add default via 10.0.2.2 
 
 
 # éditer le fichier /etc/resolv.conf afin de définir les nom DNS.
```

![](./imgs/dialog-error.png)
Attention ceci n'est vraiment que pour des testes , Au reboot ceci est PERDU !!

## Redhat/CentOS configuration réseau

L'ensemble des fichiers de configuration son bien entendu dans le répertoire /etc sous RedHat il existe un répertoire nommé sysconfig qui comprend des configuration système.

### Définition du hostname

Commençons par nommé notre système et activer le système de réseaux, pour ce faire nous éditons le fichier **/etc/sysconfig/network** voici un exemple du fichier:

```
NETWORKING=yes
HOSTNAME=Votre_hostname.VotreDomaine.com
```


Bien entendu en modifiant la Variable NETWORKING à NO le service de réseau serai désactivé... Qui voudrais faire ça ??

### Définition de l'adresse ip

La configuration de l'adresse ip ce fait comme suit , nous éditons le fichier **ifcfg-nomInterface** contenu dans le répertoire **/etc/sysconfig/network-scripts/** donc si nous manipulons l'interface eth0 nous éditerons le fichier : **/etc/sysconfig/network-scripts/ifcf-eth0**.
Voici 2 exemple de configuration une avec requête DHCP et l'autre avec ip fixe.

```
DEVICE="eth0"
BOOTPROTO="dhcp"
HWADDR="00:0C:29:CC:F6:96"
IPV6INIT="yes"
MTU="1500"
NM_CONTROLLED="yes"
ONBOOT="yes"
TYPE="Ethernet"
```

Version ip fixe:

```
DEVICE=eth0
BOOTPROTO=static
BROADCAST=192.168.1.255
IPADDR=192.168.1.5
NETMASK=255.255.255.0
NETWORK=192.168.1.0
ONBOOT=yes
GATEWAY=192.168.1.1
```



## Utilisation d'un système avec plusieurs cartes réseaux

Nous avons vu dans la section précédente que la carte réseau se nommé eth0, comme vous pouvez vous en douter si nous avions 2 cartes réseau nous aurions eth0 et eth1. Le chiffre incrémente pour chaque nouvelle carte détectée.
eth est pour les cartes filaire éthernet , si vous avez une autre carte réseau par exemple de type wireless cette dernière sera nommé wlan , ici je parle de convention car le nom est définie par le driver / module du kernel qui est chargé , si vous avez un driver propriétaire il serai possible que ce dernier choisisse un autre nom. On ne sait jamais avec le code propriétaire ;-) .
Bien que les cartes sans fil sont un peu particulière, car contrairement à la carte réseaux physique généralement administré par l'administrateur du système , pour la carte sans fil nous sommes dans l'obligatoire de permettre à l'utilisateur de choisir son réseau et de géré l'authentification de ce dernier. Pour le moment je vais me concentré sur les cartes filaires s'il y a une demande je prendrai le temps pour couvrir le système de carte sans fil.
Situation lorsque le système démarrer et initialise les cartes réseaux :

* le système boot, charge grub et charge kernel
* le kernel détecte le matériel présent et charge les modules en conséquence.
* s'il y a une carte réseaux intel dans la slot PCI 1 , le système charge le module et créer l'interface eth0
* s'il y a une carte réseaux broadcom dans la slot PCI 2 , le système charge le module et créer l'interface eth1

Donc nous assignons nos configuration au interface par exemple eth0 == 192.168.1.10 et eth1 == 10.10.10.10, hypothétiquement nous avons donc 2 réseaux auquel notre machine à accès. Je vais partir du principe que notre système est une machine Debian/Ubuntu , voici donc le fichier de configuration **/etc/network/interface** :

```
 # Intel Card
auto eth0
iface eth0 inet static
	address 192.168.1.10
	netmask 255.255.255.0
	network 192.168.1.0
	broadcast 192.168.1.255
	gateway 192.168.1.1
 
 # Broadcom Card
auto eth1
iface eth1 inet static
	address 10.10.10.10
	netmask 255.255.255.0
	network 10.10.10.0
	broadcast 10.10.10.255
	gateway 10.10.10.1
```

Continuons la mise en situation, pas de chance la carte mère du système meurt , trop chose , court circuit peu importe, résultat on change de carte mère , mais heureusement le disque dur n'est pas touché , comme Linux détecte les périphériques au démarrage nous n'avons PAS besoin de réinstaller la machine. Cependant maintenant la nouvelle carte mère à une carte réseau intégré (onboard), résultat j'ai maintenant 3 cartes réseaux disponibles  : carte intégré , l'intel et la broadcom, à l'origine cette situation causé un problème sur les système GNU/Linux Le système lors du démarrage détecte l'ensemble des cartes réseaux résultat la carte intégré devient eth0 , l'intel eth1 , ... Le résultat été que lors de l'ajout d'une carte réseaux nous nous retrouvions a configurer le réseau de la machine , ce n'est pas critique mais quand l'administrateur du système n'est pas physiquement sur les lieux et qu'un tech réalise l'opération ceci peut être très problématique.

Vous vous rappeler de udev , non ?? nous l'avions vu dans la formation Linux 101 à la fin complètement , udev nous permet de réalisé des opérations sur un évènement de Kernel pour faire de la gestion de matériel , nous avions vu qu'il est possible de définir un lien symbolique , de démarrer un script lors de la détection du matériel . Udev nous permet aussi de modifier / associer un nom à un périphérique selon des critères .

De nos jours lors qu'une nouvelle carte réseau est détecté par le système **udev** va éditer le fichier **/etc/udev/rules.d/70-persistent-net.rules**. Regardons un exemple de son contenu. 

```
 # This file was automatically generated by the /lib/udev/write_net_rules
 # program, run by the persistent-net-generator.rules rules file.
 #
 # You can modify it, as long as you keep each rule on a single
 # line, and change only the value of the NAME= key.
 
 # PCI device 0x8086:/sys/devices/pci0000:00/0000:00:03.0 (e1000)
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="08:00:27:e8:c1:19", ATTR{dev_id}=="0x0", ATTR{type}=="1", KERNEL=="eth*", NAME="eth0"
```

En d'autre mot suite à cette opération votre carte réseau à TOUJOURS le même nom selon la mac adresse utilisé , comme nous pouvons le voir par le critère de configuration : ATTR{address}=="08:00:27:e8:c1:19".
Ceci veut aussi dire que si vous changer votre carte réseau dans la machine, la nouvelle carte réseau aura le nom eth1, à moins que vous ne changer la configuration dans udev.
warning / attention  :	Il est donc important lors de changement de physique de la carte réseau de penser à ce point car sinon udev identifiera la nouvelle carte avec un nom différent. Il est possible aussi que nous voulions se comportement ... l'important est de le connaitre.

### Carte réseau avec ip multiple

Quelle sont les motivations d'avoir plusieurs carte dans un système ?

* Avoir une machine dans 2 réseaux distinct ; Sur le plan de la sécurité des réseaux ceci est discutable cependant c'est une raison
* Avoir une machine / firewall / router qui gère le trafic réseau : Nous retrouvons un peu le point précédent cependant ceci est dans une optique de gestion des flux , l'utilisation de 2 cartes réseaux  est essentiel.
* Avoir plusieurs adresse ip dans le même réseaux pour une machine : PAS une bonne raison , et nous allons voir pourquoi.

GNU/Linux nous permet de définir de multiple adresses ip  sur une même carte réseau / interface . Cette adresse ip se définie sur l'interface nommé eth0:0 , eth0:1 , ...
Donc la première partie comprend l'interface de la carte réseau primaire et par la suite on ajoute des ip "virtuel" sur l'interface avec :0, :1 , etc. Il est possible aussi de définir des nom telle que eth0:wan , eth0:lan,, bien que ceci est possible je l'ai vu rarement utilisé.

L'ensemble de la configuration présenté préalablement pour définir une adresse ip temporaire ou permanente s'applique aussi bien pour cette adresse ip additionnel , voici un exemple pour la définition d'une adresse ip sur l'interface eth0:0 sous Ubuntu:

```
auto lo
iface lo inet loopback
 
auto eth0
iface eth0 inet static
	address 192.168.10.119
	netmask 255.255.255.0
	network 192.168.10.0
	broadcast 192.168.10.255
	gateway 192.168.10.254
 
# ip virtuel
auto eth0:0
iface eth0:0 inet static
	address 192.168.10.200
	netmask 255.255.255.0
	network 192.168.10.0
	broadcast 192.168.10.255
```

![](./imgs/pictograms-aem-0032-slipping_rearward.png)
ATTENTION: si vous utilisez cette technique gardé en mémoire que bien que les packets réseaux peuvent entrer dans le système sur les 2 adresses IP , lorsque les packets ressorte les packets auront comme origine l'ip définie sur l'interface eth0 !
