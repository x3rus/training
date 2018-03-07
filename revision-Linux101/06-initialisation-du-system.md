# Initialisation du système d'exploitation GNU/Linux

Dans cette leçon nous verrons l'initialisation du système d'exploitation de GNU/Linux, nous commencerons par le système d'initialisation bios jusqu'au login du système d'exploitation. Bien entendu nous ne pourrons pas voir l'ensemble dans les détails, mais l'objectif est d'avoir une idée du processus. Nous ne verrons pas le détail des fichiers de configuration à ce stade, ni comment diagnostiquer un problème pendant ces étapes, mais après cette leçon vous saurez identifier les étapes qui rende disponible le système.

## Mise en fonction du système (BIOS)

Sans rentrer dans les détails pour commencer il y a le bios (Basic Input Output System)

Le BIOS a un rôle essentiel pour le fonctionnement de la carte mère :

* il initialise tous les composants de la carte mère, du chipset et de certains périphériques ;
* il identifie tous les périphériques internes et externes qui lui sont connectés ;
* si cela n'a pas déjà été fait il initialise l'ordre de priorité des périphériques d'entrée ;
* il démarre le système d'exploitation présent sur le premier périphérique disponible.

Le Power-on self-test (POST, l’auto-test au démarrage) désigne la première étape de ce processus plus général appelé amorçage.

Lors de cette étape, le BIOS teste la présence des divers périphériques et tente de leur attribuer les ressources nécessaires à un fonctionnement sans conflit. Le POST terminé, le contrôle est cédé au chargeur d'amorçage, dont le rôle est de démarrer le système d'exploitation.


## Chargeur d'armorçage (boot loader)

Une fois le **POST** du **BIOS** fini ce dernier charge le disque dur, plus particulièrement les permiers secteur du disque appeler le **MBR** (Master Boot Record). Sa taille est de 512 octets. Le **MBR** contient la table des partitions (les quatre partitions primaires) du disque dur. Il contient également une routine d'amorçage dont le but est de charger le système d'exploitation, ou le chargeur d'amorçage (boot loader) s'il existe, présent sur la partition active.

Dans les 512 octects il y a un petit programme ce dernier permet de charger le système d'exploitation, sous Linux , nous utilisons un chargeur d'amorçage, actuellement le plus populaire est **GRUB**, il existe aussi d'autre logiciel telle que **lilo** , etc.

**GRUB** étant trop volumineux pour tenir dans 512 octects ce dernier est divisé en 3 étapes:

![](./imgs/768px-GNU_GRUB_on_MBR_partitioned_hard_disk_drives.svg.png)

Comme nous pouvons le voir dans la représentation ci-dessus :

* **Stage 1** :  boot.img est le logiciel d'initialisation du boot loader qui débute le processus de boot , ce dernier va charger charger l'information de l'étape 1.5
* **Stage 1.5** : core.img cette section comprend les "drivers" afin de pouvoir lire la partition contenant le reste du logiciel , en effet la partition /boot peut être ext3, ext4, btrf , ... Le système à besoin de charger le driver approprié afin d'être en mesure de lire le stage 2
* **stage 2** : /boot/grub contient l'ensemble du logiciel d'amorçage vous pouvez le lire quand le système d'exploitation est chargé. C'est un logiciel donc il est possible d'avoir plusieurs fonctionnalité , la majorité du temps ce logiciel ne permet que de choisir un noyau (kernel) et d'amorcer le démarrage de ce dernier.

Voici le contenu du répertoire /boot/grub :

```bash
username@hostname:~$ ls -l /boot/grub/
total 2216
drwxrwxr-x 2 root root    4096 Nov 27 11:25 fonts
-rw-r--r-- 1 root root     699 Oct 16 15:03 gfxblacklist.txt
-r--r--r-- 1 root root   12223 Feb 27 08:12 grub.cfg
-rw-rw-r-- 1 root root    1024 Mar 24 12:38 grubenv
drwxrwxr-x 2 root root   12288 Nov 27 11:50 i386-pc
drwxrwxr-x 2 root root    4096 Nov 27 11:25 locale
-rw-r--r-- 1 root root 2226340 Nov 27 11:50 unicode.pf2
```

Nous retrouvons les fichiers:

* **grub.cfg** : Fichier de configuration de grub
* **i386-pc** : ce répertoire contient les fichiers du logiciel de grub , si vous listez le contenu du répertoire vous constaterez qu'il y a un grand nombre de fichier car grub fut développé de manière modulaire.
* **fonts** :  des polices de caractère
* **locale** : liste de chaînes de caractère propre à une langue , telle que le français , l'allemand , etc

Nous verrons dans une autre leçon comment configurer **grub** ou réaliser des modifications dans la configuration. Une fois le logiciel chargé en mémoire dans l'étape 2 grub lit le fichier de configuration **/boot/grub/grub.cfg** ce fichier de configuration liste les noyaux (kernel) disponible qui sont tous dans le répertoire /boot . Le système grub à toujours un noyaux par défaut qu'il va sélectionner pour initialiser le démarrage. Lorsque le noyau est chargé par grub ce dernier lui passe des arguments telle que la partition contenant le root ( / ) du système d'exploitation.

## Le noyau (kernel) et l'initrd

Pour rappel Le noyau est le cœur du système, c'est lui qui s'occupe de fournir aux logiciels une interface pour utiliser le matériel. Lors de l'initialisation  le est composé de 2 fichier le kernel qui contient les instructions proprement dite et il y a le fichier **initrd** qui est associé à son kernel . Le fichier **initrd** (Initial Ramdisk) contient un mini système d'exploitation , ce dernier permet de charger des modules que le kernel à besoin , il permet aussi de réaliser des initialisations requise pour le kernel.

Voici un exemple d'utilisation de l'**initrd** : Vous avez acheter un contrôleur RAID pour votre serveur Ultra performant qui est supporter par Linux. Le problème est que le code source n'est pas libre , cependant il fournisse le module , le module sera présent dans le fichier **initrd** afin que le kernel puisse se charger convenablement et aller chercher l'ensemble des informations du système d'exploitation.

Bien que l'utilisation de l'inirtd n'est pas obligatoire l'ensemble des distributions moderne utilise se système afin qu'il soit disponible dans le cas où ceci deviendrai obligatoire, offrant par le fait même une plus grande flexibilité.

![](./imgs/dialog-error.png)
Le fichier **initrd** est associé à un kernel il n'est PAS possible de prendre ce fichier et de l'associer à un autre kernel  , car les modules / drivers qui compose ce fichier n'est utilisable que par le kernel pour lequel ils furent créé. Il existe une commande pour créer un nouveau fichier **initrd** lors de la mise en place d'un kernel. Ceci est automatique lors de la mise à jour via le système de package.

Donc récapitulation :

* Le système s'initialise grâce au BIOS
* Le BIOS charge le boot loader (GRUB)
* L'utilisateur choisi son kernel et l'**initrd** qui lui est associé

Étape 4 ! Le boot loader (GRUB) charge le fichier **initrd** en mémoire et mount le mini système d'exploitation en RW, une fois accésible il exécute le fichier /init ( fichier contenu dans le système **initrd**) le fichier /init est un script qui réalise plusieurs opération telle que le chargement de module kernel / drivers , ... Une fois le script finalisé , le système remount la vraie partition root ( / ) par dessus le mini système **initrd** afin d'initialisé le Vraie système d'exploitation GNU/Linux.La dernière instruction du script init de l'**initrd**  est d'exécuté l'initialisation du système d'exploitation final en exécutant le script /sbin/init présent sur la partition root ( / ) de l'OS Linux .


```bash
user@hostname:~/demo_init$ # Copie du fichier
user@hostname:~/demo_init$ cp /boot/initrd.img-3.11.0-14-generic .
user@hostname:~/demo_init$ 
user@hostname:~/demo_init$ # visualisation du type de fichier
user@hostname:~/demo_init$ file initrd.img-3.11.0-14-generic
initrd.img-3.11.0-14-generic: gzip compressed data, from Unix, last modified: Thu Dec 19 12:38:30 2013
user@hostname:~/demo_init$ 
user@hostname:~/demo_init$ # extraction
user@hostname:~/demo_init$ mv initrd.img-3.11.0-14-generic initrd.img-3.11.0-14-generic.gz
user@hostname:~/demo_init$ gunzip initrd.img-3.11.0-14-generic.gz
user@hostname:~/demo_init$ file initrd.img-3.11.0-14-generic
initrd.img-3.11.0-14-generic: ASCII cpio archive (SVR4 with no CRC)
user@hostname:~/demo_init$ 
user@hostname:~/demo_init$ ls
initrd.img-3.11.0-14-generic
user@hostname:~/demo_init$ 
user@hostname:~/demo_init$ cpio -idmv < initrd.img-3.11.0-14-generic
[[ OUTPUT COUPÉ ]]
usr/lib/i386-linux-gnu/libXext.so.6
usr/lib/i386-linux-gnu/libdatrie.so.1
usr/lib/i386-linux-gnu/libgraphite2.so.3
usr/share
usr/share/fonts
usr/share/fonts/truetype
usr/share/fonts/truetype/ttf-dejavu
usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf
108565 blocks
user@hostname:~/demo_init$ 
user@hostname:~/demo_init$ ls --color
bin  conf  etc  init  initrd.img-3.11.0-14-generic  lib  run  sbin  scripts  usr
user@hostname:~/demo_init$ 
user@hostname:~/demo_init$ # Visualisa du script d'initialisation
user@hostname:~/demo_init$ vim -R init
```

## Processus INIT

Donc récapitulation :

* Le système s'initialise grâce au BIOS
* Le BIOS charge le boot loader (GRUB)
* L'utilisateur choisi son kernel et l'initrd qui lui est associé
* L'**initrd** est chargé, les modules kernel sont chargés et le root ( / ) est mounté

Étape 5 , le premier processus est lancé **/sbin/init**, **init** (abréviation de initialisation) est le programme sous Unix qui lance toutes les autres tâches. Il s'exécute comme un démon et typiquement il a un identifiant de processus (**PID**) de 1. Ce dernier va faire en sorte que l'ensemble du système soit opérationnel.Ce processus est toujours présent sur le système, il ne sera arrêté que lors de l'arrêt de la machine. En utilisant la commande ps , il est possible de voir ce processus :

```bash
user@host:~$ ps aux | head -3
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   3884  2036 ?        Ss   Mar03   0:00 /sbin/init
root         2  0.0  0.0      0     0 ?        S    Mar03   0:00 [kthreadd]
```

Comme vous l'aurez peut-être devinez TOUS les autres programme découle donc de ce programme, nous le voyons bien avec la commande **pstree**:

```bash
user@host:~$ pstree | head -7
init-+-NetworkManager-+-dhclient
     |                |-dnsmasq
     |                `-2*[{NetworkManager}]
     |-acpid
     |-apache2---5*[apache2]
     |-atd
     |-avahi-daemon---avahi-daemon
```

La déclaration du fichier **/sbin/init** est programmé en dur dans le kernel cependant il est possible de passer en argument à grub un autre nom de fichier , grub ce charge par la suite d'informer le kernel de ne pas utiliser le nom de fichier par default ,nous le verrons plus tard lors du debugging.

Il existe plusieurs logiciel qui réalise ce processus init , le standard maintenant est **SystemD**.
