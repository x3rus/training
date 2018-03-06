# Présentation des périphériques sous GNU/Linux

## Répertoire /dev  et les fichiers qui le compose

Telle que mentionné lors de la présentation du système de fichier le répertoire **/dev** contient la définition sous forme de fichier des périphériques disponible sur le système. Donc si on liste les fichiers contenu dans le répertoire nous constaterons qu'il y en a beaucoup, une petite explication s'impose afin de comprendre leurs signification.

Il existe 2 types de device :

* **blocks** : les périphériques par blocks transmettent ou reçoivent les informations sous forme de paquets (block) d'octets, d'une taille fixe : c'est par exemple le cas des supports de mémoire de masse (disquettes, disques durs...).
* **caractères** : Les périphériques de caractères ont comme caractéristique de transmettre et recevoir les informations octet par octet : c'est par exemple le cas des ports séries ou parallèles, des modems, etc.

Pour connaître le type du device utilisez la commande ls -l , le premier caractère nous donne cette information, **C** pour caractère et **B** pour block. Voici un exemple pour le périphérique de la console et du disque dur sata :

```bash
utilisateur@hostname:~$ ls -l /dev/sda /dev/sda1 /dev/console  
crw------- 1 root root 5, 1 Jan 27 12:16 /dev/console
brw-rw---- 1 root disk 8, 0 Jan 27 12:16 /dev/sda
brw-rw---- 1 root disk 8, 1 Jan 27 12:16 /dev/sda1
```

Voici un tableau explicatif des noms et leurs rôles:

| Fichier     | Majeur | Mineur | B/C |	Périphérique                        |
|:----------- |:------:|:------:|:---:|-------------------------------------|
|/dev/mem |	1 |	1 |	c |	accès direct à la mémoire centrale|
|/dev/fd0 |	2 |	0 |	b |	premier lecteur de disquettes|
|/dev/hda |	3 |	0 |	b |	disque maître sur le premier port IDE|
|/dev/hda2 |	3 |	2 |	b |	seconde partition primaire sur ce disque|
|/dev/hdb |	3 |	64 |	b |	disque esclave sur le premier port IDE|
|/dev/hdb5 |	3 |	69 |	b |	première partition logique sur ce disque|
|/dev/tty1 |	4 |	1 |	c |	première console virtuelle|
|/dev/lp0 |	6 |	2 |	c |	troisième port parallèle (imprimante)|
|/dev/sda |	8 |	0 |	b |	premier disque dur SCSI / SATA / USB drive , ...|
|/dev/sda3 |	8 |	3 |	b |	troisième partition sur ce disque|
|/dev/sdb |	8 |	16 |	b |	deuxième disque dur SCSI/ SATA / USB drive , ...|
|/dev/psaux |	10 |	1 |	c |	port PS/2 (souris)|
|/dev/bus/usb/001 |	11 |	0 |	c |	Premier Device USB|
|/dev/scd0 |	11 |	0 |	b |	premier CD-ROM SCSI|
|/dev/video0 |	81 |	0 |	c |	Acquisition vidéo|

Il existe aussi des pseudo-périphérique, qui existe que virtuellement mais qui offre de vraie fonctionnalité :

* **/dev/zero** : génére des zéros
* **/dev/random** : génère de l'aléatoire
* **/dev/null** : constitue un trou noir à octets, et notamment utilisé pour se débarrasser des fichiers et des affichages
* **/dev/loop0** : permet de créer de faux périphériques de type block (stockage) à partir de fichiers créés avec la commande dd

Le nom du fichier est indépendant du driver ou matériel utilisé se sont des noms générique, attention ceci n'est pas le cas pour tous les unix , FreeBSD par exemple nomme les périphériques selon le driver.

À présent que nous sommes en mesure d'identifier les périphériques grâce à leur nom, nous allons voir comment le système fait en sorte pour communiquer avec ces derniers. Si nous prenons le cas du premier disque dur SATA sur le système , **/dev/sda**, si je liste les partitions sur le disque j'utiliserai la commande **fdisk** , comme ceci :

```bash
utilisateur@hostname:~$ sudo fdisk -l /dev/sda 
Disk /dev/sda: 60.0 GB, 60011642880 bytes
255 heads, 63 sectors/track, 7296 cylinders, total 117210240 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0xeede9d79
 
   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048    58593279    29295616   83  Linux
/dev/sda2        58595326   117209087    29306881    5  Extended
/dev/sda5        58595328    64475135     2939904   82  Linux swap / Solaris
/dev/sda6        64477184   117209087    26365952   83  Linux
```

### Périphérique identifiant  Majeur / Minor

Le fichier **/dev/sda** est un fichier spécial il ne suffit pas de créer un fichier vide dans **/dev** avec le bon nom pour que ceci fonction , il faut que le fichier est les bonnes propriétés ! Il est important de définir le bon type **block** ou **caractere**, de plus il faut définir une valeur majeur (major) et mineur (__minor__). Ces 2 valeurs en combinaisons  avec le type permet d'identifier le périphérique avec lequel nous désirons interagir. L'ensemble des communications avec le matériel est réalisé par le Noyau (**kernel**) , ce dernier conserve un tableau qui lui permet de faire la correspondance avec périphérique.

Voici un exemple pour les disques dur __sata__ :

| Majeur | 	Mineur | Device     | 	Description 						|
|:------:|:-------:|:---------- |---------------------------------------|
|8 |	0 | 	  /dev/sda |  	 Premier disque dur dans son ensemble |
|8 | 	1 |	  /dev/sda1    | La preminère partition du Premier Disque dur |
|8 | 	2 |	  /dev/sda2    |	 La deuxième partition du Premier Disque dur|
|8 |	16| 	  /dev/sdb |	 Deuxième disque dur dans son ensemble|
|8 |	17| 	  /dev/sdb1| 	 Première partition Deuxième Disque dur|

Donc le Majeur 8 représente les __devices__ sur le BUS SCSI , SATA, ... le mineur représente le détail avec lequel  nous interagissons !

Quelle est le processus de création de ces fichiers ? Car si je branche une clef USB, le système va créer les fichiers  /dev/sdb et /dev/sdb1 , /dev/sdb2 ,... . Le système incrémente automatiquement  de /dev/sda pour prendre le prochain disponible donc /dev/sdb .

Ceci est magnifique et encore une fois merci d'avoir modernisé le système, grâce à udev , par contre j'aimerai fournir l'information, sans le système automatique . Car sous le capot il y a un processus .

Le système udev utilise la commande /bin/mknod pour faire la création des fichiers contenu dans /dev , voici un exemple :
