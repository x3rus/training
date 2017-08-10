# Permission spécial fichier ( Sticky bits , SetUid , SetGid )

Petite capsule suite à une proposition d'un participant à la formation que j'apprécie. Nous allons voir les [Sticky bit](https://en.wikipedia.org/wiki/Sticky_bit), le [Setuid et SetGid](https://fr.wikipedia.org/wiki/Setuid) sous Linux . Je n'avais pas couvert cette partie lors de la présentation des permissions ou alors juste effleuré le concept. 

Nous allons prendre un peu de temps , ceci me donnera l'occasion de préparer la prochaine formation :P 

## Sticky bit 

Le sticky bit est utiliser pour réalisé une limitation de suppression de fichiers au propriétaire seulement , vous retrouverez cette permissions sur TOUS les systèmes GNU/Linux en utilisation. Si vous ne l'avez pas, car il y a eu une erreur de manipulation il est même possible que certaine application fonctionne mal . 

```bash
$ ls -ld /tmp/
drwxrwxrwt 11 root root 260 Aug  9 17:21 /tmp/
```

Donc ce répertoire tous le monde peut écrire dedans , car ceci est un répertoire temporaire pour les applications , mais si tous le monde peut écrire dedans il y a aussi un risque que n'importe qui supprime des données dedans. Grâce au **Sticky bit** ceci ne peut pas arrivé c'est une protection.

J'ai 2 utilisateurs pour le besoin de l'exercice :
* x3rus-formations : Utilisateur pour les formations
* x3rus : mon utilisateur "régulier"

* Je fait la création d'un fichier avec l'utilisateur x3rus-formations dans /tmp :

```bash
x3rus-formation $ touch /tmp/unFichier
x3rus-formation $ chmod 777 /tmp/unFichier
x3rus-formation $ ls -ld /tmp/unFichier       
-rwxrwxrwx 1 x3rus-formations x3rus-formations 0 Aug  9 17:30 /tmp/unFichier
```

* Si j'essaye de supprimer le fichier avec l'utilisateur x3rus ça ne fonctionnera PAS même si j'ai l'ensemble des permissions , à cause du sticky bit:

```bash
x3rus $ rm /tmp/unFichier 
rm: cannot remove '/tmp/unFichier': Operation not permitted
  # Pas de problème pour réaliser des modifications au conteneur 
x3rus $ echo "blabla " >> /tmp/unFichier
```

* Mais POURQUOI ? La raison est simple quand on comprend le système de fichier Linux, je sais pas si c'est à cause de l'âge mais bon ça fait partie du parcourt autant le partager .

![](./imgs/directory-structure.png)

Voici une représentation du FICHIER de type répertoire qu'est : **/tmp** , en fait ce fichier est une liste de pointeurs conteneur le nom donné par l'humain vers les inodes , les emplacements sur le disque du fichiers. Un jour on prendra peut-être le temps de voir la partie du fichier :P .
En d'autre mot on a les permissions de modifier le contenu du fichier donc l'inode de ce dernier, mais pas supprimer la référence que /tmp à du fichier. Comme le système de fichier ne libère pas l'inode tant qu'il y a une référence on peut pas le supprimer . Même si on peut écrire dedans.

* Alors qui peut ? L'utilisateur qui possède le fichier ou **ROOT** bien entendu 

```bash
x3rus-formations $ rm /tmp/unFichier
```

Bien entendu le **sticky bit** peut être assigné à n'importe quelle répertoire

## SetGID et SetUID

Ces flags auront un comportement différent s'il est attribué à un répertoire ou un fichier. Il est important de soulever que l'application de cette configuration peut être un soucis de sécurité ... Donc prenez le temps de bien comprendre la situation . Nous allons débuter avec un fichier puis voir pour un répertoire :

### SetGid sur un Fichier

Pour rappel par défaut quand un processus est lancé par un utilisateur , ce dernier est exécuté sous le nom de l'utilisateur et il aura l'ensemble des permissions en terme de groupe auquel il est membre. 

De plus lors de la création de fichier l'utilisateur propriétaire sera , l'utilisateur (oui je sais impressionnant :P ) et le groupe primaire de l'utilisateur ! Le groupe est souvent ennuyeux selon la situation . 

L'utilisation du **setGID** vous permettra de force un groupe qui sera utiliser à l'exécution . Je vais faire une démonstration , voici un petit script c [sleep-write-file.c](./code/sleep-write-file.c) :

```c
 #include<stdio.h>
 #include <unistd.h>

int main()
{
        printf("start App and wait");
        sleep(10);

        FILE *fp;
        fp=fopen("/tmp/test-bin.txt", "w");
        fprintf(fp, "Testing...\n");
        fclose(fp);

        printf("Fin...");
}
```

Le script fait pas grand chose il démarre , attend 10 seconde , ouvre un fichier en écriture et écrit Testing dedans. Je vais le compiler et l'exécuter normalement pour voir le comportement avant et après l'assignation du **setGID**.

```bash
$ gcc -o a sleep-write-file.c
$ ls -l a
-rwxr-xr-x 1 x3rus x3rus 8664 Aug 10 08:23 a
$ ./a
start AppWait ...Fin...
$ ls -l /tmp/test-bin.txt
-rw-r--r-- 1 x3rus x3rus 11 Aug 10 08:24 /tmp/test-bin.txt
```

Pour le moment normale exactement le comportement attendu , maintenant je vais lister les groupes qui m'appartienne et assigne le setgid au fichier pour le groupe tty :

```bash
$ id                          
uid=1000(x3rus) gid=1000(x3rus) groups=1000(x3rus),3(sys),4(adm),10(wheel),19(log),994(docker)
```

Comme on peut le voir mon groupe primaire et le même que mon utilisateur et je n'ai PAS le groupe **tty** dans mes permissions 

```bash
$ sudo chown :tty a
$ ls -ld a                    
-rwxr-xr-x 1 x3rus tty 8664 Aug 10 08:23 a 
$ sudo chmod g+s a
$ ls -la a                    
-rwxr-sr-x 1 x3rus tty 8664 Aug 10 08:23 a
```

Évidement vous allez voir le comportement tous le monde ne peut pas changer les permissions pour cette opération les risques serait trop grand :P .
C'est partie pour l'exécution

```bash
$ rm /tmp/test-bin.txt
$ ./a                         
start AppWait ...Fin...
$ ls -ld /tmp/test-bin.txt 
-rw-r--r-- 1 x3rus tty 11 Aug 10 08:28 /tmp/test-bin.txt
```

Comme nous pouvons le voir le fichier est propriétaire de l'utilisateur et d'un groupe auquel il n'est pas membre **tty** dans le cas présent, car le processus fut exécuter avec ce groupe comme primaire. 

* Utilisation possible :
    * Permettre l'exécution d'un programme sans offrir l'ensemble des permissions du groupe , ce qui donnerai accès à l'ensemble des fichiers traiter par l'application
    * Réaliser un wrapper pour docker , vous ne voulez pas leur permettre d'exécuter n'importe que en étant dans le groupe .
* Alternative :
    * Utiliser sudo , le problème est que sudo est au niveau de l'utilisateur et non le groupe , mais au moins vous avez une traçabilité dans la logs.

Vous pouvez voir les fichiers qui ont se flags sur votre système en utilisant la commande __find__.

```bash
 $ sudo find  / -perm -g+s      
 /usr/bin/wall
 /usr/bin/locate
```

* Pourquoi j'ai fait une application C qui a généré un binaire et pas un script bash ou python :P ?

Ce n'est pas pour le plaisir au contraire :P , le problème est que ça ne fonctionne pas avec un script :P . La raison est simple si nous reprenons le même script en bash [sleep-write-file.sh](./code/sleep-write-file.sh). 

Le première ligne est comme ceci : 

> #!/bin/bash

Résultat il démarre l'interpréteur de commande , qui va lire le contenue du fichier , donc ce devrait être lui à changer mais l'impacte est trop grand. De plus ceci augmenterai significativement les risques au niveau de sécurité qu'une personne modifie le contenue.


### SetUid sur un Fichier

Le concept pour le **setUID** est exactement le même mais sur un fichier , je ne vais que faire la démonstration .

```bash
$ getent passwd http
http:x:33:33:http:/srv/http:/usr/bin/nologin
$ id http
uid=33(http) gid=33(http) groups=33(http)

$ sudo chown http a 
$ sudo chmod u+s a
$ ls -l a                     
-rwsr-xr-x 1 http x3rus 8664 Aug 10 08:23 a 
```

Nous allons réalisé l'exécution :

```bash

$ ./a

[ ... Dans un autre terminal ... ] 

$ ps aux | grep '/a'           
http     11984  0.0  0.0   4192   600 pts/2    S+   08:40   0:00 ./a

$ ls -l /tmp/test-bin.txt 
-rw-r--r-- 1 http x3rus 11 Aug 10 08:41 /tmp/test-bin.txt
```

Nous voyons clairement que le processus ./a est exécuté avec l'utilisateur **http** et que le groupe est x3rus car c'est ce que le fichier générer nous indique et non le groupe primaire de l'utilisateur http. Bien entendu il est possible de combiné setUID et setGID 

```bash
$ sudo chown :tty a
$ sudo chmod u+s a
$ sudo chmod g+s a
$ ls -la a                    
-rwsr-sr-x 1 http tty 8664 Aug 10 08:23 a
$ ./a                         
start AppWait ...Fin...
$ ls -la /tmp/test-bin.txt    
-rw-r--r-- 1 http tty 11 Aug 10 08:44 /tmp/test-bin.txt
```

C'est magique :P 

### SetGid sur un répertoire

Le comportement sur un fichier de type répertoire est différent , l'opération aura pour but de conserver le propriétaire groupe ou utilisateur lors de la création d'un fichier .  Voyons un exemple :

```bash
x3rus $ cd /tmp
x3rus $ mkdir toto
x3rus $ chmod 777 toto/
x3rus $ ls -ld toto
drwxrwxrwx 2 x3rus x3rus 40 Aug 10 16:58 toto/ 

x3rus-formations $ cd /tmp/toto
x3rus-formations $ touch fichier-par-autre-utilisateur 
x3rus-formations $ ls -ld fichier-par-autre-utilisateur                                
-rw-r--r-- 1 x3rus-formations x3rus-formations 0 Aug 10 17:01 fichier-par-autre-utilisateur
```

Le système ce comporte comme il se doit donc le fichier appartiens à l'utilisateur et son groupe primaire , cependant le résultat peut ne pas être idéal surtout si on veut conservé le groupe propriétaire . Nous pouvons donc utiliser le setGid pour que le groupe assigné au répertoire précédent soit conservé .

```bash
x3rus $ chmod g+s toto/
x3rus $ ls -ld toto/
drwxrwsrwx 2 xerus xerus 60 Aug 10 17:01 toto/

x3rus-formations $ touch avec-le-setgid
x3rus-formations $ ls -ld avec-le-setgid
-rw-r--r-- 1 x3rus-formations xerus 0 Aug 10 17:04 avec-le-setgid
```

Super malheureusement ça ne fonctionne qu'avec les fichiers de type fichier et non répertoire en fait ça va fonctionné mais le setgid n'est pas réactivé dans les sous répertoires, démonstration :

```bash
x3rus-formations $ ls -ld .
drwxrwsrwx 2 xerus xerus 80 Aug 10 17:04 . 


x3rus-formations $ mkdir unRepertoire
x3rus-formations $ ls -ld unRepertoire
drwxr-sr-x 2 x3rus-formations xerus 40 Aug 10 17:06 unRepertoire

x3rus-formations $ cd unRepertoire
x3rus-formations $ touch rien 
x3rus-formations $ ls -ld rien 
-rw-r--r-- 1 x3rus-formations xerus 0 Aug 10 17:06 rien 
```

En fait ça fonctionne **WOOWWW** c'est nouveau :P , avant c'était un problème :P 

* Une alternative est d'utiliser les ACL Linux pour les fichiers qui inclue l'assignation de permission et de propriétaire et ceci en mode héritage aussi 

### SetUid sur un répertoire

Cette opération n'est pas possible , ce n'est pas interprété , voici un exemple :

```bash
x3rus $ cd /tmp
x3rus $ mkdir toto-user
x3rus $ chmod 777 toto-user
x3rus $ chmod u+s toto-user

x3rus-formations $ cd /tmp/toto-user
x3rus-formations $ touch avec-setuid
x3rus-formations $ ls -ld avec-setuid
-rw-r--r-- 1 x3rus-formations x3rus-formations 0 Aug 10 17:09 avec-setuid
```

Même avec root ça ne fonctionne pas 

```bash
root $ cd /tmp/toto-user/
root $ touch avec-root
root $ ls -ld avec-root
-rw-r--r-- 1 root root 0 Aug 10 17:10 avec-root
```

* Dans le cas présent l'alternative est d'utiliser les ACL Linux pour les fichiers qui inclue l'assignation de permission et de propriétaire et ceci en mode héritage aussi 
