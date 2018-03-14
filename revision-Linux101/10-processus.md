# Compréhension des processus

## Définition d'un processus

Un processus est un programme en cours d'exécution. Par exemple, chaque fois que l'on lance la commande **ls**, un processus est créé durant l'exécution de la commande.

Un processus est identifié par un numéro unique que l'on appelle le **PID** (**P**rocess **ID**entifiant).

Un processus dispose d'un processus père que l'on appelle le **PPID** (**P**arent **PID**).

La particularité d'un processus est de s'exécuter avec les droits accordés à l'utilisateur qui a lancé la commande. Ceci participe fortement à la sécurité du système. Ainsi, si un utilisateur contracte un programme malveillant (un virus par exemple), le processus sera soumis au droit d'accès de cet utilisateur, et ne pourra pas effectuer des opérations non autorisées (comme par exemple modifier le fichier de mots de passe).

Au démarrage de l'ordinateur, le système charge le noyau Linux qui se charge de l'initialisation du matériel et de la détection des périphériques. Ceci fait, il démarre ensuite le processus **init** qui a comme particularité d'être le premier processus et de toujours utiliser le **PID** 1. Ce processus démarre ensuite des processus noyaux (dont le nom est noté entre crochets), et les premiers processus systèmes.

Chaque processus a ainsi un père (sauf **init**), et peut être à son tour le père d'autres processus, etc.

## Visualisation des processus

### Visualisation des processus avec PS

On peut visualiser les processus qui tournent sur une machine avec la commande : **ps** (options), les options les plus intéressantes sont **-e** (affichage de tous les processus) et **-f** (affichage détaillée). La commande **ps -ef** donne un truc du genre :

```bash
admuser@srv01:~$ ps -ef 
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 12:36 ?        00:00:00 /sbin/init
root         2     0  0 12:36 ?        00:00:00 [kthreadd]
[ ... OUTPUT COUPÉ ... ]
root       733     1  0 12:36 tty2     00:00:00 /sbin/getty -8 38400 tty2
root       735     1  0 12:36 tty3     00:00:00 /sbin/getty -8 38400 tty3
root       737     1  0 12:36 tty6     00:00:00 /sbin/getty -8 38400 tty6
root       742     1  0 12:36 ?        00:00:00 /usr/sbin/xinetd -dontfork -pidfile /var/run/xinetd.pid -stayalive -inetd_compat -inetd_ipv6
root       743     1  0 12:36 ?        00:00:00 acpid -c /etc/acpi/events -s /var/run/acpid.socket
root       746     1  0 12:36 ?        00:00:00 cron
daemon     747     1  0 12:36 ?        00:00:00 atd
root       800     1  0 12:36 tty1     00:00:00 /sbin/getty -8 38400 tty1
whoopsie   866     1  0 12:36 ?        00:00:00 whoopsie
```

La signification des différentes colonnes est la suivante:

* **UID** nom de l'utilisateur qui a lancé le processus
* **PID** correspond au numéro du processus
* **PPID** correspond au numéro du processus parent
* **C** au facteur de priorité : plus la valeur est grande, plus le processus est prioritaire
* **STIME** correspond à l'heure de lancement du processus
* **TTY** correspond au nom du terminal
* **TIME** correspond à la durée de traitement du processus
* **CMD** correspond au nom du processus.

Certains processus sont permanents, c'est à dire qu'ils sont lancés au démarrage du système et arrêtés uniquement à l'arrêt du système. On appelle ces processus des **daemons**, le terme démon est une francisation, **daemon** sont des abréviations.
Pour voir les processus d'un seul utilisateur, vous pouvez taper :

```bash
admuser@srv01:~$ ps -u admuser
  PID TTY          TIME CMD
 1143 ?        00:00:00 sshd
 1144 pts/0    00:00:00 bash
 1259 pts/0    00:00:00 ps
```

D'un UNIX à l'autre la sortie peut changer. Sous LINUX par exemple **ps -Al** permet une sortie assez riche, en faisant un **man ps**, vous aurez l'éventail de tous les paramètres possibles.

La commande **pstree** permet de visualiser l'arbre des processus. L'option -p permet de visualiser les **PID** de chaque processus.

```bash
admuser@srv01:~$ pstree -l
init-+-acpid
     |-atd
     |-cron
     |-dbus-daemon
     |-dhclient3
     |-6*[getty]
     |-rsyslogd---3*[{rsyslogd}]
     |-sshd---sshd---sshd---bash---pstree
     |-udevd---2*[udevd]
     |-upstart-socket-
     |-upstart-udev-br
     |-whoopsie---{whoopsie}
     `-xinetd
```

Il est aussi possible d'avoir un affichage différent avec la commande **PS**, nous utilisons l'option -o (output) avec les arguments que l'on veut afficher :

```bash
admuser@srv01:~$ sudo ps -eo pid,user,args,pmem,pcpu
[sudo] password for admuser: 
  PID USER     COMMAND                     %MEM %CPU
    1 root     /sbin/init                   0.3  0.1
    2 root     [kthreadd]                   0.0  0.0
[ ... OUTPUT COUPÉ ... ]
  746 root     cron                         0.1  0.0
  747 daemon   atd                          0.0  0.0
  800 root     /sbin/getty -8 38400 tty1    0.1  0.0
  866 whoopsie whoopsie                     0.7  0.0
 1019 root     sshd: admuser [priv]         0.6  0.0
 1143 admuser  sshd: admuser@pts/0          0.2  0.0
 1144 admuser  -bash                        1.3  0.0
 1258 root     [kworker/u2:1]               0.0  0.0
 1331 root     sudo ps -eo pid,user,args,p  0.3  2.5
``` 

Vous trouverez l'ensemble des options disponible dans le man page de la commande **ps** (**man ps**) dans la section **STANDARD FORMAT SPECIFIERS**

### Visualisation du processus dans /proc

Le système de fichier **proc** est un __pseudo-système__ de fichiers qui est utilisé comme interface avec les structures de données du noyau. Il est généralement monté sur **/proc**. La plupart des fichiers sont en lecture seule, mais quelques uns permettent la modification de variables du noyau.

* /proc/PID-NUMBER 	Il existe un sous-répertoire pour chaque processus en cours. Le sous-répertoire rend comme nom le PID du processus. Chaque sous-répertoire contient les pseudo-fichiers et pseudo-répertoires suivants.
	* /proc/PID-NUMBER/cmdline  : 	Ce fichier contient la ligne de commande complète du processus, sauf si le processus est un zombie. Dans ce dernier cas, il n'y a rien dans le fichier : une lecture reviendra après avoir lu 0 caractère. Les arguments de la ligne de commande apparaissent comme un ensemble de chaînes séparées de caractères NUL, avec un octet NUL supplémentaire après le dernier argument.
	* /proc/PID-NUMBER/cwd  : Il s'agit d'un lien symbolique sur le répertoire de travail courant du processus.
	* /proc/PID-NUMBER/environ 	Ce fichier contient l'environnement du processus. Les entrées sont séparées par des octets nuls (« \0 »), et il devrait y en avoir un à la fin du fichier. Ainsi, pour afficher l'environnement du processus numéro 1, utilisez :

	```
		(cat /proc/548/environ; echo) | tr "\000" "\n"
	```
	* /proc/PID-NUMBER/exe :	ce fichier est un lien symbolique représentant le chemin réel de la commande en cours d'exécution. Ce lien symbolique peut être déréférencé normalement ; tenter de l'ouvrir fera que l'on ouvrira le fichier exécutable. Vous pouvez même taper /proc/PID-NUMBER/exe pour lancer une copie du même processus que celui du pid indiqué. Dans un processus multithread, le contenu de ce lien symbolique n'est plus disponible si le thread principal est déjà terminé
	* /proc/PID-NUMBER/fd 	Il s'agit d'un sous-répertoire contenant une entrée pour chaque fichier que le processus a ouvert. Chaque entrée a le descripteur du fichier pour nom, et est représentée par un lien symbolique sur le vrai fichier. Ainsi, 0 correspond à l'entrée standard, 1 à la sortie standard, 2 à la sortie d'erreur, etc...
	* /proc/PID-NUMBER/limits 	Ce fichier indique les limites souple et stricte ainsi que les unités de mesure de chaque limite de ressources du processus (voir getrlimit(2)). Le fichier est protégé de telle sorte que seul l'UID réel du processus puisse le lire.
	* /proc/PID-NUMBER/root 	Linux, et Unix en général, supporte une notion de racine du système de fichiers pour chaque processus, configurable avec l'appel système chroot(2). Ce fichier est un lien symbolique qui pointe sur le répertoire racine du processus, et se comporte comme exe, fd/ ...
	* /proc/PID-NUMBER/stat 	Informations sur l'état du processus. Ceci est utilisé par ps(1). La définition se trouve dans /usr/src/linux/fs/proc/array.c.
	* /proc/PID-NUMBER/status 	Fournit l'essentiel des informations de /proc/PID-NUMBER/stat et /proc/PID-NUMBER/statm dans un format plus facile à lire pour les humains. Voici un exemple :

	```bash
	$ cat /proc/$$/status
	Name:   bash
	State:  S (sleeping)
	Tgid:   3515
	Pid:    3515
	PPid:   3452
	TracerPid:      0
	Uid:    1000    1000    1000    1000
	Gid:    100     100     100     100
	FDSize: 256
	Groups: 16 33 100
	VmPeak:     9136 kB
	VmSize:     7896 kB
	VmLck:         0 kB
	VmHWM:      7572 kB
	VmRSS:      6316 kB
	VmData:     5224 kB
	VmStk:        88 kB
	VmExe:       572 kB
	VmLib:      1708 kB
	VmPTE:        20 kB
	Threads:        1
	SigQ:   0/3067
	SigPnd: 0000000000000000
	ShdPnd: 0000000000000000
	SigBlk: 0000000000010000
	SigIgn: 0000000000384004
	SigCgt: 000000004b813efb
	CapInh: 0000000000000000
	CapPrm: 0000000000000000
	CapEff: 0000000000000000
	CapBnd: ffffffffffffffff
	Cpus_allowed:   00000001
	Cpus_allowed_list:      0
	Mems_allowed:   1
	Mems_allowed_list:      0
	voluntary_ctxt_switches:        150
	nonvoluntary_ctxt_switches:     545
	```


### Visualisation des processus avec TOP

Nous avions déjà entrevue la commande **top** principalement lors de la compilation d'une application nous avions vue **htop** qui finalement est relativement comme **top** mais avec de la couleur et quelques option en plus .

Exemple de la visualisation de **top** :

```bash
admuser@srv01:~$ top
 
top - 12:00:02 up 1 day, 23:23,  1 user,  load average: 0.06, 0.03, 0.05
Tasks:  69 total,   1 running,  68 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.0%us,  0.3%sy,  0.0%ni, 99.3%id,  0.3%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:    506432k total,   299544k used,   206888k free,    29220k buffers
Swap:   976892k total,        0k used,   976892k free,   224000k cached
 
  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
 2194 admuser   20   0  9652 1368  764 S  0.3  0.3   0:00.01 sshd
 2298 admuser   20   0  2820 1116  884 R  0.3  0.2   0:00.01 top
    1 root      20   0  3540 1936 1304 S  0.0  0.4   0:00.85 init
    2 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kthreadd
    3 root      20   0     0    0    0 S  0.0  0.0   0:00.69 ksoftirqd/0
    5 root       0 -20     0    0    0 S  0.0  0.0   0:00.00 kworker/0:0H  
[ ... OUTPUT COUPÉ ...]
```

Ce nous permet de voir en temps réelle la mémoire utilisé le processus qui prend le plus de ressource , l'utilisation du CPU ( utilisateur (us), Système (sy) , Changement de priorité (ni) , En attente (id), Attente d'accès Input/output (wa) , ...)

Lorsque la commande **top** fonctionne, les lettres suivantes permettent de changer son fonctionnement :

* h : affiche l'aide
* q : quitte la commande **top**
* M : tri les processus par utilisation de la mémoire (du plus gourmand au plus sobre)
* P : tri les processus par utilisation du processeur (du plus gourmand au plus sobre)
* s : permet de changer la durée de rafraîchissement de **top**
* k : permet d'envoyer un signal à un processus


## Visualisation des fichiers (port , socket, ...) ouvert par les processus

**lsof** permet de voir les fichiers ouvert par les processus , il y a un grand nombre d’argument possible je vous laisserai le plaisir de les découvrir je ferai une présentation simple à vous de chercher le reste.
Si vous exécutez **lsof** comme un simple utilisateur l'information des processus afficher ne sera que les processus dont vous êtes le propriétaire .

```bash
admuser@srv01:~$ lsof  | wc -l
320
admuser@srv01:~$ sudo lsof  | wc -l
730
```

De plus comme simple utilisateur vous aurez plusieurs "permission denied".

Voici un exemple de l'affichage pour le processus __sshd__ avec les droits administrateur :

```bash
admuser@srv01:~$ sudo lsof  | grep ssh
sshd       613       root  cwd       DIR        8,1     4096          2 /
sshd       613       root  rtd       DIR        8,1     4096          2 /
sshd       613       root  txt       REG        8,1   527680     148233 /usr/sbin/sshd
sshd       613       root  mem       REG        8,1    47040         91 /lib/i386-linux-gnu/libnss_files-2.15.so
sshd       613       root  mem       REG        8,1    42652         90 /lib/i386-linux-gnu/libnss_nis-2.15.so
sshd       613       root  mem       REG        8,1    30520         92 /lib/i386-linux-gnu/libnss_compat-2.15.so
sshd       613       root  mem       REG        8,1    83776         80 /lib/i386-linux-gnu/libresolv-2.15.so
sshd       613       root  mem       REG        8,1    13672        796 /lib/i386-linux-gnu/libkeyutils.so.1.4
[ ... OUTPUT COUPÉ ... ]
sshd      2194    admuser    1u      CHR        1,3      0t0       5577 /dev/null
sshd      2194    admuser    2u      CHR        1,3      0t0       5577 /dev/null
sshd      2194    admuser    3u     IPv4      11607      0t0        TCP 10.0.2.15:ssh->10.0.2.2:47502 (ESTABLISHED)
sshd      2194    admuser    4u     unix 0xdcf27680      0t0      11636 socket
sshd      2194    admuser    5u     unix 0xdcf26900      0t0      11849 socket
sshd      2194    admuser    6r     FIFO        0,8      0t0      11851 pipe
```

Comme vous pouvez le constater nous retrouvons les fichier  mais aussi les connexion réseaux , les sockets , etc.

## Comprendre le load average

Le **load average** désigne, sous les systèmes UNIX, une moyenne de la charge système, une mesure de la quantité de travail que fait le système durant la période considérée. Celle-ci est disponible via la commande **top** ou **uptime**, ou encore via le fichier système **/proc/loadavg**.

```bash
$ uptime
load average: 1.27, 0.92, 0.73
```

Le premier nombre, 1.27, est une moyenne de la charge calculée sur une minute. Le second nombre est calculé sur cinq minutes, et le troisième sur quinze minutes. Il est un très bon indicateur de la (sur)charge de travail d'un système, mais ne permet pas d'en identifier la cause.

La charge représente le nombre de processus en train d'utiliser ou en train d'attendre le processeur plus, sous la majorité des systèmes, le nombre de processus bloqués. Ceci rend l'interprétation du nombre plus difficile. Le nombre maximum de processus réellement en cours d'exécution dépend du nombre de processeurs : 1 pour un monoprocesseur, 2 pour un biprocesseur… Une charge de 2 indique qu'il y a forcément un processus en attente sur un monoprocesseur, mais peut être simplement deux processus en cours d'exécution sur un biprocesseur.

Cas d'un seul processeur, et d'optimisations systèmes (par opposition aux optimisations applicatives, à ne jamais négliger)

* La charge est < 1

Une charge < 1 indique qu'il n'y a pas assez de processus pour occuper complètement la machine. La "compétition" pour le processeur est donc inexistante; ce dernier exécute les instructions rapidement et est libéré. Un problème de performance proviendra donc certainement des demandes de traitement qui ne parviennent pas assez rapidement à la machine.
→ Pour améliorer les performances: effectuer plus de tâches simultanées, augmenter le débit des requêtes…

* La charge est constamment à 1

Une charge de 1 constante signifie qu'il y avait à tout moment un et un seul processus en état de travail. Aucun processus n'a donc "attendu son tour" pour être traité par le processeur. Cependant, s'il y a un processus unique qui occupe constamment le processeur, il pourrait éventuellement s'exécuter plus rapidement sur un processeur plus puissant. En effet, même si la file d'attente est vide, le processus "en cours" peut avoir besoin de plus de rapidité.
→ Pour améliorer les performances: s'il y a un seul processus, en ajouter et observer la charge. Sinon, l'équilibre est atteint, et plus de tâches à effectuer impliqueront une amélioration au niveau processeur, mémoire et/ou entrées-sorties.

* La charge est supérieure à 1

Ceci ne signifie pas forcément qu'un processeur plus rapide résoudrait le problème. En effet, la charge inclut généralement les processus en attente d'entrées-sorties. Un processus dans ce cas sera donc comptabilisé, mais il « attend » un périphérique d'I/O, et non pas le processeur. Il faut donc prêter attention aux autres affichages des commandes comme top; où l'utilisation processeur globale est également indiquée. Si le processeur est inactif (idle) à 90 % mais que la charge est élevée, un processeur plus véloce n'y changera rien. S'il reste « collé » à 100 % d'utilisation, alors il est certainement en cause. (autrement dit : un load >1 n'indique une contention sur le processeur que si, et seulement si, le idle = 0.0 )
→ Pour améliorer les performances: examiner le taux d'utilisation global du processeur. Minimiser si possible les I/O (la quantité de mémoire vive est elle suffisante?). Agir ensuite en conséquence sur les points faibles identifiés.

## Prioritisation des processus 

### Gestion des priorité d'ordonnancement des processus (nice)

**nice** est une commande disponible sur le système d'exploitation UNIX et autres systèmes compatibles tels que Linux. Cette commande pointe directement vers un point d'entrée du __kernel__ portant le même nom, elle permet de changer le niveau de priorité d'un processus déterminé. La priorité la plus élevée correspond à un niveau de -20, tandis que la plus basse correspond à +19. Le niveau de priorité par défaut d'un processus est celui de son processus parent, et vaut généralement zéro.

Nice est utile dès que plusieurs processus requièrent plus de puissance CPU que celui-ci peut fournir. Dans ce cas, le processus ayant la priorité la plus élevée bénéficiera de plus de puissance de la part du CPU. En revanche, si le CPU n'est pas utilisé à 100 %, alors un processus de faible priorité pourra quand même bénéficier d'une part de puissance pouvant aller jusqu'à 99 %. Seul un super-utilisateur (root) peut assigner des niveaux de priorité élevés.

Le mécanisme de répartition de la charge CPU en fonction de la priorité des processus est effectué par l'ordonnanceur de taches (task scheduler). L'algorithme mis en œuvre peut varier d'une implémentation à une autre, les pourcentages de CPU alloués entre deux processus se partageant 100 % du temps machine peuvent donc être très variables entre diverses versions de Unix, Linux ou autres BSD.

La commande **renice** permet quant à elle de modifier le niveau de priorité d'un processus en cours d'exécution.

Exemple d'utilisation de **nice** lors du lancement de l'application :

```bash
admuser@srv01:~$ nice -n +19 free -m
```

Si l'application est déjà en cours d’exécution et que vous désirer réduire la priorité vous utiliserez le **PID** du processus et utilisez **renice**.

```bash
admuser@srv01:~$ ps aux | grep cron
root       746  0.0  0.1   2620   808 ?        Ss   Jul07   0:00 cron
admuser@srv01:~$ renice -n +19 746
renice: failed to set priority for 746 (process ID): Operation not permitted
 # Bien entendu il faut avoir les droits sur le processus.
admuser@srv01:~$ sudo renice -n +19 746
[sudo] password for admuser: 
746 (process ID) old priority 0, new priority 19
```

### Gestion des priorité d'ordonnancement des accès disque (ionice)

Il est aussi possible de définir une priorisation de l'accès disque :

**Ionice** Ce programme définit ou lit la priorité et la classe d’ordonnancement des d’entrées/sorties d’un programme. S’il n’y a pas de paramètre ou si seul -p est donné, **ionice** demandera la classe et la priorité actuelle d’ordonnancement d’entrées/sorties pour ce processus. Un processus peut appartenir à l’une de ces trois classes d’ordonnancement :

**Idle** : Un programme s’exécutant avec une priorité d’entrées/sorties « idle » obtiendra du temps pour accéder au disque quand aucun autre programme n’a demandé d’entrées/sorties sur les disques dans une période donnée. L’impact des processus avec une classe d’ordonnancement d’entrées/sorties « idle » sur l’activité normale du système devrait être nul. Cette classe d’ordonnancement de processus ne prend pas de priorité en paramètre. Cette classe d’ordonnancement est permise pour un simple utilisateur (depuis Linux 2.6.25).

**Best effort** : C’est la classe par défaut d’ordonnancement pour chaque processus qui n’a pas demandé une priorité spécifique d’entrées/sorties. Les programmes héritent des paramètres de politesse (« nice ») du processeur pour les priorités d’entrées/sorties. Cette classe prend une priorité en paramètre dans la gamme 0-7, où le nombre le plus bas sera d’une priorité plus haute. Les programmes en cours ayant la même priorité « best effort » sont servis l’un après l’autre. Un processus qui n’a pas demandé de priorité d’E/S utilise la classe d’ordonnancement none mais l’ordonnanceur d’E/S traitera un tel processus comme s’il était de la classe best effort. La priorité dans la classe best effort sera dynamiquement dérivée du niveau de politesse CPU de la priorité du processus d’E/S (égale à (politesse_cpu + 20) / 5).

**Real time** :  La classe d’ordonnancement RT donne en premier l’accès au disque, sans se soucier des autres exécutions sur le système. De ce fait, la classe RT doit être utilisée avec attention, car elle peut « affamer » d’autres processus. Comme la classe « best effort », 8 niveaux de priorité sont définis dénotant la période de temps qu’un processus donné recevra dans chaque fenêtre d’ordonnancement. Cette classe d’ordonnancement n’est pas permise pour un simple utilisateur (c’est-à-dire, non-superutilisateur).

Exemple d'utilisation disponible  sur la man page http://www.man-linux-magique.net/man1/ionice.html 

### Gestion des limite CPU pour un processus (cpulimit)

Il existe un autre système de priorisation des processus ou plutôt de limitation d'un processus au niveau de son utilisation de CPU. avec la commande cpulimit il est possible d'indiquer à une processus de n'utiliser que 50% du CPU. À ce jour ( Q3 2014 ) je n'ai jamais utiliser cette fonctionnalité. Voici un exemple d'utilisation:

```bash
 # Demarrage d un processus
 # Démarrage du processus bigloop avec max 40% de CPU
admuser@srv01:~$ cpulimit --exe bigloop --limit 40
admuser@srv01:~$ cpulimit --exe /usr/local/bin/bigloop --limit 40 
 
 # Limitation d un processus en cours 
 # processus avec le pid 2960 limitation du cpu a 200%
admuser@srv01:~$ cpulimit --pid 2960 --limit 200 
```

Il est important de comprendre le pourcentage utilisé , si vous avez 1 CPU le système utilise en 0% et 100% , si vous avez 4 CPU le système peut utilise entre 0% et 400% donc dans l'exemple numéro 2 le processus peut utilise jusque la moitié de la puissance des processus.

http://cpulimit.sourceforge.net/


## Gestion des signaux

Les signaux sont des mécanismes permettant de manipuler et de communiquer avec des processus sous Linux. Le sujet des signaux est vaste; nous traiterons ici quelques uns des signaux et techniques utilisées pour contrôler les processus.

Un signal est un message spécial envoyé à un processus. Les signaux sont asynchrones; lorsqu'un processus reçoit un signal, il le traite immédiatement, sans même terminer la fonction ou la ligne de code en cours. Il y a plusieurs douzaines de signaux différents, chacun ayant une signification différente. Chaque type de signal est caractérisé par son numéro de signal, mais au sein des programmes, on y fait souvent référence par un nom. Sous Linux, ils sont définis dans /usr/include/bits/signum.h (vous ne devriez pas inclure ce fichier directement dans vos programmes, utilisez plutôt <signal.h>).

Lorsqu'un processus reçoit un signal, il peut agir de différentes façons, selon l'action enregistrée pour le signal. Pour chaque signal, il existe une action par défaut, qui détermine ce qui arrive au processus si le programme ne spécifie pas d'autre comportement. Pour la plupart des signaux, le programme peut indiquer un autre comportement -- soit ignorer le signal, soit appeler un gestionnaire de signal, fonction chargée de traiter le signal. Si un gestionnaire de signal est utilisé, le programme en cours d'exécution est suspendu, le gestionnaire est exécuté, puis, une fois celui-ci terminé, le programme reprend.

Le système Linux envoie des signaux aux processus en réponse à des conditions spécifiques. Par exemple, SIGBUS (erreur de bus), SIGSEGV (erreur de segmentation) et SIGFPE (exception de virgule flottante) peuvent être envoyés à un programme essayant d'effectuer une action non autorisée. L'action par défaut pour ces trois signaux est de terminer le processus et de produire un ficher core.

Un processus peut également envoyer des signaux à un autre processus. Une utilisation courante de ce mécanisme est de terminer un autre processus en lui envoyant un signal SIGTERM ou SIGKILL(Quelle est la différence? Le signal SIGTERM demande au processus de se terminer; le processus peut ignorer la requête en masquant ou ignorant le signal. Le signal SIGKILL tue toujours le processus immédiatement car il est impossible de masquer ou ignorer SIGKILL.). Une autre utilisation courante est d'envoyer une commande à un programme en cours d'exécution. Deux signaux "définis par l'utilisateur" sont réservés à cet effet: SIGUSR1 et SIGUSR2. Le signal SIGHUP est également parfois utilisé dans ce but, habituellement pour réveiller un programme inactif ou provoquer une relecture du fichier de configuration.

### Les différents signaux

Pour connaître la liste des signaux, il suffit de consulter la page de manuel de signal (section 7) :

```
$ man 7 signal
 ...
 Signal     Valeur    Action   Commentaire
 ---------------------------------------------------------------------
 SIGHUP        1       Term    Déconnexion détectée sur le terminal
                               de contrôle ou mort du processus de
                               contrôle.
 SIGINT        2       Term    Interruption depuis le clavier.
 SIGQUIT       3       Core    Demande « Quitter » depuis le clavier.
 SIGILL        4       Core    Instruction illégale.
 SIGABRT       6       Core    Signal d’arrêt depuis abort(3).
 SIGFPE        8       Core    Erreur mathématique virgule flottante.
 SIGKILL       9       Term    Signal « KILL ».
 SIGSEGV      11       Core    Référence mémoire invalide.
 SIGPIPE      13       Term    Écriture dans un tube sans lecteur.
 SIGALRM      14       Term    Temporisation alarm(2) écoulée.
 SIGTERM      15       Term    Signal de fin.
 SIGUSR1   30,10,16    Term    Signal utilisateur 1.
 SIGUSR2   31,12,17    Term    Signal utilisateur 2.
 SIGCHLD   20,17,18    Ign     Fils arrêté ou terminé.
 SIGCONT   19,18,25    Cont    Continuer si arrêté.
 SIGSTOP   17,19,23    Stop    Arrêt du processus.
 SIGTSTP   18,20,24    Stop    Stop invoqué depuis tty.
 SIGTTIN   21,21,26    Stop    Lecture sur tty en arrière-plan.
 SIGTTOU   22,22,27    Stop    Écriture sur tty en arrière-plan.
```

Les signaux les plus connus sont les trois suivants :

* **SIGHUP** (signal n°1) : pour beaucoup de services réseaux, la réception du signal n°1 lui indique de lire sa configuration. Par exemple, cela permet d'indiquer au processus apache (serveur web) de relire sa configuration, sans avoir a arrêter et redémarrer le processus.
* **SIGKILL** (signal n°9) : termine un processus (arrêt brutal). Utile lorsque le SIGTERM ne marche pas (processus planté).
* **SIGTERM** (signal n°15) : demande au processus de s'arrêter (arrêt propre).

#### Envoie de signaux ( kill )

La commande **kill** permet d'envoyer un signal au processus. Syntaxe :

```bash
$ kill -<numéro du signal ou nom du signal> <PID du processus>
```

Exemple d'utilisation de KILL :

```bash
$ kill -1 12345
$ kill -SIGTERM 12345
```

On peut connaitre le **PID** du processus en utilisant la commande **ps**, ou bien utiliser la commande **pidof** 

```bash
$ pidof cupsd
2571
$ kill -15 2571
```


La commande **killall** permet d'indiquer le nom du processus plutôt que son **PID**, et va envoyer le signal à tous les processus possédant ce nom. Exemple :

```bash
$ xeyes & ; xeyes & ; xeyes &
$ killall xeyes
```


Utilisé sans option, les commandes **kill** et **killall** envoient le signal n°15 (arrêt propre).
