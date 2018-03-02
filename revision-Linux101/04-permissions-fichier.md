# Permissions et propiétaire des fichiers

Les systèmes d'exploitation inspirés d'Unix (dont Linux fait partie) possèdent la capacité de définir de façon poussée la gestion de droits d'accès aux divers fichiers de votre OS.

Les **droits d'accès** définissent la possession d'un fichier ou d'un répertoire à un utilisateur et à un groupe d'utilisateurs. Ils gèrent aussi quelles actions les utilisateurs ont le droit d'effectuer sur les fichiers, selon qu'ils sont propriétaire du fichier, membre du groupe propriétaire du fichier ou ni l'un ni l'autre. La possession et la gestion des permissions associées s'effectuent individuellement avec chaque fichier.

* Le présent article est un document d'explication à propos des droits d'accès. Les sections "[Les propriétaires](http://doc.ubuntu-fr.org/droits#les_proprietaires)" et "[Les permissions](http://doc.ubuntu-fr.org/droits#les_permissions)" exposent de façon générale ce que sont ces attributs auxquels vous devrez faire face dans votre vie linuxienne.
* Les manipulations des droits d'accès des fichiers et dossiers sont abordés dans l'article « [Permissions](http://doc.ubuntu-fr.org/permissions) ».

## Les propriétaires

Par la propriété d'un fichier, on désigne à quel utilisateur appartient le fichier, qui le possède. À partir de cette possession (ou non), il sera ensuite possible de définir des permissions d'accès sur le fichier.

La possession d'un fichier se définit sur trois catégories :

* **L'utilisateur propriétaire** du fichier (**u**). Il s'agit généralement du créateur du fichier. (Prenez note qu'un fichier créé par une commande exécutée à l'aide de sudo appartiendra à l'utilisateur root ; vous serez potentiellement amené à devoir changer le propriétaire de ce fichier pour pouvoir vous en servir avec votre propre compte utilisateur.)
* **Le groupe propriétaire** du fichier (**g**). Si un utilisateur est membre d'un certain groupe qui possède la propriété d'un fichier, l'utilisateur aura aussi certaines permissions particulières sur ce fichier.
* **Les autres**, __other__, le reste du monde (**o**). Bref, tout un chacun n'étant ni propriétaire du fichier, ni membre du groupe propriétaire du fichier.

Faisons une analogie avec les voitures. Le propriétaire serait la personne au nom de laquelle la voiture est immatriculée. Le groupe propriétaire est l'ensemble des personnes qui sont inscrites en tant que conducteurs secondaires de la voiture chez l'assureur. Enfin, les autres correspond à toutes les autres personnes n'étant ni détenteur de l'immatriculation ni inscrites en tant que conducteurs de la voiture chez l'assureur.

## Les permissions

Les permissions désignent ce que les diverses catégories d'utilisateurs (propriétaire d'un fichier, membres du groupe propriétaire d'un fichier et le reste du monde) ont l'autorisation d'effectuer sur un fichier donné. Par exemple, une catégorie d'utilisateurs peut avoir accès en lecture et écriture à un fichier, alors qu'une autre catégorie à accès en lecture seulement.

Les permissions se définissent sur trois niveaux :

* **La lecture** d'un fichier : cette permission est nécessaire pour pouvoir accéder au contenu d'un fichier (écouter une piste audio, visionner un film, lire un texte, naviguer à l'intérieur d'un répertoire…). Cette permission est notée **r** (pour __read__, lire).
* **L'écriture** dans un fichier : cette permission est nécessaire pour pouvoir apporter des modifications à un fichier (corriger un texte et enregistrer les changements ; effacer les "yeux rouges" dans une photo et enregistrer la correction ; ajouter, modifier, renommer ou supprimer un fichier dans un dossier ; etc.). Cette permission est notée **w** (pour __write__, écrire).
* **L'exécution** d'un fichier : cette permission est nécessaire particulièrement pour les logiciels, afin qu'ils puissent être exécutés. Cette permission est notée **x** (pour __execute__, exécuter).

Par exemple, l'utilisateur toto dispose des droits de lecture et d'exécution sur le répertoire foo, mais pas la permission d'écriture sur ce répertoire ; toto peut donc exécuter les programmes présents dans ce répertoire et ouvrir les fichiers qu'il contient, mais ne peut pas les modifier ni en créer de nouveaux.

Pour chacune des trois catégories d'utilisateurs (propriétaire, membres du groupe propriétaire et reste du monde) sont définies ces trois permissions :

* Le propriétaire dispose ou non de la permission de lecture, d'écriture et d'exécution sur un fichier ;
* Le membre du groupe propriétaire dispose ou non de la permission de lecture, d'écriture et d'exécution sur un fichier ;
* Tous les autres utilisateurs disposent ou non de la permission de lecture, d'écriture et d'exécution sur un fichier.

Les droits sont affichés par une série de 9 caractères, associé 3 par 3 (**rwx rwx rwx**) définissent les droits des 3 identités (**u**, **g** et **o**).

## Manipulation avec la ligne de commande

### lister les permissions

Nous l'avons déjà vu mais nous n'avions pas pris le temps d’éclaircir le résultat avec la commande ls -l , le résultat nous montre les permissions. Voici un exemple:

```bash
$ ls -l
drwxrwxr-x 2 tboutry tboutry      4096 Feb  3 13:03 Documents
-rw-rw---- 1 root    root            0 Feb  3 13:00 Fichier_du_root
drwx------ 2 tboutry tboutry      4096 Feb  3 13:04 Perso
-rw-r----- 1 tboutry adm             0 Feb  3 13:01 lefichier_des_adm
-rw-rw-r-- 1 tboutry tboutry         0 Feb  3 13:01 mon_fichier
-rw-r--r-- 1 root    root         2030 Feb  3 13:00 passwd
-rw-rw-r-- 1 tboutry video   233821918 Jan 21 14:12 redirection_flux-1.ogv
```

Les droits d'accès apparaissent alors comme une liste de 10 symboles. :

```
drwxr-xr-x
```

Le premier symbole est soit « **-** », « **d** », soit « **l** », nous indiquant la nature du fichier :

* **-** : fichier
* **d** : répertoire
* **l** : lien
* **b , c , s** : pour les périphériques nous verrons ça dans la prochaine sessions...

Suivent ensuite 3 groupes de 3 symboles chacun, indiquant si le fichier (ou répertoire) est autorisé en lecture, écriture ou exécution. Les 3 groupes correspondent, dans cet ordre, aux droits du propriétaire, du groupe puis du reste des utilisateurs. Dans le paragraphe introductif, vous aurez remarqué des lettres en gras dans les termes anglais. Ce sont ces lettres qui sont utilisées pour symboliser lesdites permissions. Si la permission n'est pas accordée, la lettre en question est remplacé par « - ». Si l'on reprend les lettres données pour lecture/écriture/exécution (**read/write/execute**), nous obtenons : **rwx** et pour propriétaire/groupe/autres (**user/group/other**), nous obtenons : **ugo**

Reprenons l'exemple théorique suivant :

```
drwxr-xr-x
```

![](./imgs/permissions-linux.png)

Il se traduit de la manière suivante :

* d : c'est un répertoire.
* rwx pour le 1er groupe de 3 symboles : son propriétaire peut lire, écrire et exécuter.
* r-x pour le 2nd groupe de 3 symboles : le groupe peut uniquement lire et exécuter le fichier, sans pouvoir le modifier.
* r-x pour le 3ème groupe de 3 symboles : le reste du monde peut uniquement lire et exécuter le fichier, sans pouvoir le modifier.

### Changement de propriétaire (chown)

La commande **chown** (**ch**ange **own**er, changer le propriétaire) permet de changer le propriétaire du fichier. Seuls le super-utilisateur ou le propriétaire actuel d'un fichier peut utiliser **chown**. La commande s'utilise de la façon suivante :

```bash
 # exemple chown
$ sudo chown Mon_utilisateur fichier1
```

**chown** permet aussi de changer en une seule commande le propriétaire et le groupe du fichier :

```bash
    # exemple chown utilisateur + group 
$ sudo chown Mon_Utilisateur:le_nom_du_group fichier1
```

Le fichier __fichier1__ appartient alors à l'utilisateur Mon_Utilisateur et au groupe le\_nom\_du\_group.
Il est aussi possible d'utiliser **chown** pour ne modifier uniquement le groupe

```bash
 # exemple chown group
$ sudo chown :le_nom_du_group fichier1
```

### Changement des permissions (chmod)

L'outil **chmod** (**ch**ange **mod**e, changer les permissions) permet de modifier les permissions sur un fichier. Il peut s'employer de deux façons : soit en précisant les permissions de manière octale, à l'aide de chiffres) ; soit en ajoutant ou en retirant des permissions à une ou plusieurs catégories d'utilisateurs à l'aide des symboles **r w et x**, que nous avons présenté plus haut. Nous préférerons présenter cette seconde façon ("ajout ou retrait de permissions à l'aide des symboles"), car elle est probablement plus intuitive pour les néophytes. Sachez seulement que les deux méthodes sont équivalentes, c'est-à-dire qu'elles affectent toutes deux les permissions de la même manière.

De cette façon, on va choisir :

1. À qui s'applique le changement
    * **u** (user, utilisateur) représente la catégorie "propriétaire" ;
    * **g** (group, groupe) représente la catégorie "groupe propriétaire" ;
    * **o** (others, autres) représente la catégorie "reste du monde" ;
    * **a** (all, tous) représente l'ensemble des trois catégories.
2. La modification que l'on veut faire
    * **+** : ajouter
    * **-** : supprimer
    * **=** : ne rien changer
3. Le droit que l'on veut modifier
    * **r** : read ⇒ lecture
    * **w** : write ⇒ écriture
    * **x** : execute ⇒ exécution
    * **X** : eXecute ⇒ exécution, concerne uniquement les répertoires et les fichiers qui ont déjà une autorisation d'exécution pour l'une des catégories d'utilisateurs. Nous allons voir plus bas dans la partie des traitements récursifs l'intérêt du X.

Par exemple : 

```bash
 # supprimer les permissions a tout le monde d'écrire dans le fichier3
$ chmod o-w fichier3
```

Enlèvera le droit d'écriture pour les autres.

```bash
 # ajout permission d'exécution pour tout le monde
$ chmod a+x fichier3
```
ajoutera le droit d'exécution à tout le monde.

On peut aussi combiner plusieurs actions en même temps :

* On ajoute la permission de lecture, d'écriture et d'exécution sur le fichier fichier3 pour le **propriétaire** ;
* On ajoute la permission de lecture et d'exécution au **groupe propriétaire**, on retire la permission d'écriture ;
* On ajoute la permission de lecture aux **autres**, on retire la permission d'écriture et d'exécution.

```bash
 # modification de plusieurs droit avec chmod
$ chmod u+rwx,g+rx-w,o+r-wx fichier3
```

#### Changement des permissions en mode Octal

En octal, chaque « groupement » de droits (pour user, group et other) sera représenté par un chiffre et à chaque droit correspond une valeur :

* r = 4
* w = 2
* x = 1
* - = 0

Par exemple,

* Pour rwx, on aura : 4+2+1 = 7
* Pour rw-, on aura : 4+2+0 = 6
* Pour r--, on aura : 4+0+0 = 4

Reprenons le répertoire Documents. Ses permissions sont :

```
 # permission
drwxr-x---
```
En octal, on aura 750 :

```
    rwx        r-x        ---
 7(4+2+1)   5(4+0+1)   0(0+0+0)
```

Pour mettre ces permissions sur le répertoire on taperait donc la commande :

```bash
 # permission en octal avec chmod
$ chmod 750 Documents
```
