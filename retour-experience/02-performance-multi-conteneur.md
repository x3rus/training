
# Description 

Suite à la réalisation de mise à jour OS , j'ai du redémarrer mon serveur , bien entendu comme mon serveur est **SUPER** stable ceci n'arrive pas souvent . Suite au redémarrage j'ai eu une **GROSSE** peur , car l'ensemble des mes conteneurs n'était PAS disponible :-/. 

Comme l'ensemble de mes services sont dans des conteneurs ceci veut dire que RIEN fonctionne ... Moment de panique , analyse et diagnostique du problème ... Nous allons donc comprendre ce qui c'est passer

# Information sur le système 

J'utilise Ubuntu 16.04 avec Docker 1.12.1 , provenant du dépôt officiel de docker.

# Présentation de la situation 

## Premier redémarrage ( 2017-05-13 )

* date 22:19:00 Fin du __reboot__ début du démarrage de docker

TODO : faire l'ajout du fichier de logs valider ce qu'il y a a cleaner 

Fichier de Logs de docker : [journalctl -u docker.service](./docker-logs-2017-05-13)

* l'ensemble des commandes docker freeze , hang

* Dans les logs

    ```
    May 12 22:21:51 PROD.x3rus.com docker[1963]: time="2017-05-12T22:21:51.775193221-04:00" level=info msg="Loading containers: start."
    May 12 22:23:39 PROD.x3rus.com docker[1963]: ................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................
    May 12 22:24:54 PROD.x3rus.com docker[1963]: ................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................
    ```

* Ça donne pas l'impression d'avancer donc j'arrête le service ( **MAUVAISE IDEE** )

    ```
    May 12 22:35:51 PROD.x3rus.com docker[1963]: time="2017-05-12T22:35:51.552260287-04:00" level=info msg="Processing signal 'terminated'"


    May 12 22:37:19 PROD.x3rus.com docker[1963]: time="2017-05-12T22:37:19.253096908-04:00" level=warning msg="libcontainerd: container 73329aacf8d22d5bb43fb9b33cb83f243b84aa87e3f78b6b51da7af802fdee68 restart canceled"
    May 12 22:37:19 PROD.x3rus.com docker[1963]: time="2017-05-12T22:37:19.263729011-04:00" level=warning msg="libcontainerd: container 0ccf206017be3f29bf224c6d1801df5e53574b1cdd5d2438ab0993b668c43b19 restart canceled"
    May 12 22:37:19 PROD.x3rus.com docker[1963]: time="2017-05-12T22:37:19.273282337-04:00" level=warning msg="libcontainerd: container 8efe40d2b2e00360398e156f3b7de97d11cb6bf45ea4b050f290092b22f4c802 restart canceled"
    May 12 22:37:19 PROD.x3rus.com docker[1963]: time="2017-05-12T22:37:19.280343888-04:00" level=warning msg="libcontainerd: container 87e80ea633768d0ec1c4ed4d848b976c42fd77f13d197551372f7e8c23ebaf71 restart canceled"
    May 12 22:37:19 PROD.x3rus.com docker[1963]: time="2017-05-12T22:37:19.472164501-04:00" level=warning msg="libcontainerd: container 7d85ca80bb739a24837354c55bd21e64736e69f3b76177770b3dbf7fb172d464 restart canceled"
    May 12 22:37:21 PROD.x3rus.com systemd[1]: docker.service: State 'stop-sigterm' timed out. Killing.
    May 12 22:37:21 PROD.x3rus.com systemd[1]: docker.service: Main process exited, code=killed, status=9/KILL
    May 12 22:37:21 PROD.x3rus.com systemd[1]: Stopped Docker Application Container Engine.
    May 12 22:37:21 PROD.x3rus.com systemd[1]: docker.service: Unit entered failed state.
    May 12 22:37:21 PROD.x3rus.com systemd[1]: docker.service: Failed with result 'signal'.

    ```

* Je redémarre le service docker 

    ```
    May 12 22:37:21 PROD.x3rus.com systemd[1]: Starting Docker Application Container Engine...
    May 12 22:37:21 PROD.x3rus.com docker[8687]: time="2017-05-12T22:37:21.750568942-04:00" level=info msg="libcontainerd: new containerd process, pid: 8696"
    May 12 22:37:22 PROD.x3rus.com docker[8687]: time="2017-05-12T22:37:22.903312694-04:00" level=info msg="[graphdriver] using prior storage driver \"aufs\""
    May 12 22:37:23 PROD.x3rus.com docker[8687]: time="2017-05-12T22:37:23.020104275-04:00" level=warning msg="libcontainerd: unknown container fad8f424de821d1429e1feadd0768a2a43193cd005c62b0f8058f854f1453c49"

    ```

* Après un certain temps 

    ```
    May 12 22:37:27 PROD.x3rus.com docker[8687]: time="2017-05-12T22:37:27.440690658-04:00" level=warning msg="libcontainerd: client is out of sync, restore was called on a fully synced container (8efe40d2b2e00360398e156f3b7de97d11cb6bf45ea4b050f290092b22f4c802)."
    May 12 22:37:28 PROD.x3rus.com docker[8687]: time="2017-05-12T22:37:28.087785280-04:00" level=warning msg="libcontainerd: client is out of sync, restore was called on a fully synced container (391b51116efe062ddb9322a557e99a379cc44adbfcf63637f88fe1e2b705ce25)."

    ```

* Ceci est probablement du au __restart__ en plein milieu :-/ 

    ```
    May 12 22:37:43 PROD.x3rus.com docker[8687]: time="2017-05-12T22:37:43.336745742-04:00" level=info msg="Removing stale sandbox dc57d9b52748ebcedf30b2768907063226a241c23f16510e144fb7f21aa06f25 (1da346e53eb87204f111412382de8a4d21b9432965a02c470e76da83a58bf628)"
    May 12 22:37:49 PROD.x3rus.com docker[8687]: time="2017-05-12T22:37:49.431967676-04:00" level=error msg="getEndpointFromStore for eid 361d956323da4d834214cbcb6989f198063a2ed5951c5ed84b58db0fca0e7390 failed while trying to build sandbox for cleanup: could not find endpoint 361d956323da4d834214cbcb6989f198063a2ed5951c5ed84b58db0fca0e7390: []"
    May 12 22:37:49 PROD.x3rus.com docker[8687]: time="2017-05-12T22:37:49.432007536-04:00" level=info msg="Removing stale sandbox f057ff048638e7c209aad8404537e962bf4f691af319e396946cf95acf62668c (73329aacf8d22d5bb43fb9b33cb83f243b84aa87e3f78b6b51da7af802fdee68)"
    ```

* Je constate avec **iostat** qu'il y a beaucoup d'activité sur **md3** répertoire où est stocker les conteneurs 

    ```bash
    $ iostat 4 10
    avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.13    0.00    0.22   11.41    0.00   88.24

    Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
    sda              83.25         0.00      2073.00          0       8292
    sdb              83.25         0.00      2073.00          0       8292
    md2               0.00         0.00         0.00          0          0
    md3             518.00         0.00      2072.00          0       8288
    ```

* Après un certain temps vers 23:00 finalement le service revient. Bon ça a pas pris 23 minutes :P 

* Situation stabilisé mais clairement PAS corrigé 

## Reprise en main du problème ( 2017-05-13 )

* Redémarrage de docker ... Voir le temps que ça prends.... Peut-être aussi long que lors de l'issue #27 , l'important de savoir

```bash
$ date && sudo systemctl stop docker.service                                                                                                                                         
Sat May 13 20:56:13 EDT 2017
 ٩(◠◡◠)۶ $ date
Sat May 13 20:56:41 EDT 2017
```

* Pas d'erreur dans le logs .. 

```
May 13 20:56:22 PROD.x3rus.com systemd[1]: Stopping Docker Application Container Engine...
May 13 20:56:22 PROD.x3rus.com docker[24220]: time="2017-05-13T20:56:22.821582565-04:00" level=info msg="Processing signal 'terminated'"
[ .... ]

May 13 20:56:37 PROD.x3rus.com docker[24220]: time="2017-05-13T20:56:37.822098095-04:00" level=error msg="Force shutdown daemon"
May 13 20:56:37 PROD.x3rus.com docker[24220]: time="2017-05-13T20:56:37.822384976-04:00" level=info msg="stopping containerd after receiving terminated"
May 13 20:56:38 PROD.x3rus.com systemd[1]: Stopped Docker Application Container Engine.

```

TODO : Voir pour ajouter le fichier avec clean up ducontenu 

Full Logs pour le service docker [docker-logs-2017-05-13](./docker-logs-2017-05-13)

* Démarrage 

```bash
$ date && sudo systemctl start docker.service && date                                                                                                                                
Sat May 13 21:00:27 EDT 2017
Sat May 13 21:09:15 EDT 2017
```

* Logs du démarrage

```
May 13 21:00:52 PROD.x3rus.com docker[12121]: ......................................................................................................................................................................................................................................................................................................time="2017-05-13T21:00:52.517664771-04:00" level=info msg="Firewalld running: false"

[.... 10 fucking MINUTES ... long quand tu attends ... ] 

May 13 21:00:59 PROD.x3rus.com docker[12121]: time="2017-05-13T21:00:59.516851144-04:00" level=info msg="Default bridge (docker0) is assigned with an IP address 172.17.0.0/16. Daemon option --bip can be used to set a preferred IP address"
May 13 21:09:07 PROD.x3rus.com docker[12121]: time="2017-05-13T21:09:07.062987727-04:00" level=warning msg="Failed to allocate and map port 443-443: Bind for 192.99.13.211:443 failed: port is already allocated"

```

* Reboot du serveur pour être certain

```bash
$ date && sudo reboot
Sat May 13 22:29:22 EDT 2017
[ ... pas fait ssh rapidement ... ]
$ date
Sat May 13 22:31:30 EDT 2017
```

### Résultat du reboot

* C'est LONG :P (après **15 minutes** toujours pas de conteneur docker)

* résultat de top, docker au top

```
top - 22:46:21 up 15 min,  4 users,  load average: 1.86, 1.68, 1.10
Tasks: 172 total,   1 running, 170 sleeping,   0 stopped,   1 zombie
%Cpu(s):  0.1 us,  0.2 sy,  0.0 ni, 87.9 id, 11.8 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem : 16422308 total, 14767556 free,   490904 used,  1163848 buff/cache
KiB Swap:  4192248 total,  4192248 free,        0 used. 15562820 avail Mem 

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND                                                                                                                  
 1838 root      20   0  922472 148332  28868 S   2.0  0.9   0:22.09 dockerd  
```

* Un peu de __io wait__ ... **iostat** le confirme 

```bash
$ iostat 4 10
Linux 4.4.0-77-generic (PROD.x3rus.com)         2017-05-13      _x86_64_        (8 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.06    0.00    0.22   11.70    0.00   88.02

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
sda              78.00         2.00      1951.00          8       7804
sdb              77.75         0.00      1951.00          0       7804
md3             483.25         0.00      1933.00          0       7732
md2               0.00         0.00         0.00          0          0

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.03    0.00    0.22   11.26    0.00   88.48

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
sda              83.50         0.00      2088.00          0       8352
sdb              83.50         0.00      2088.00          0       8352
md3             521.75         0.00      2087.00          0       8348

```

* Pas de __restart__ du service cette fois ... Je vais y arrivé :P (  Sat May 13 22:48:42 EDT 2017 )

* Docker __info__ gèle ( __Freeze / hang__ ) 

```
# Fenetre de logs :
May 13 22:49:15 PROD.x3rus.com systemd[1]: Started Docker Application Container Engine

# Fernetre cmd:
$ docker info

Containers: 10534
 Running: 13
[ ... ] 

$ date
Sat May 13 22:49:37 EDT 2017
```

# Analyse de la problématique

Le temps est significativement long , si nous regardons le résultat de la commande **docker info** nous pouvons voir qu'il y a 

> Containers: 10534
> Running: 13

Effectivement quand le système est opérationnel à 100% j'ai entre 15 et 20 conteneurs en exécution et non 10534 ... :-/ .

J'avais une mauvais compréhension du système __docker__ , dans mon esprit quand j'utilisais la commande :

```bash
$ docker run -it debian:latest bash
```

Ce dernier créé un conteneur avec un nom rigolo / aléatoire et dans ma tête ce conteneur était éphémère , qu'il ne conservait pas le conteneur .. Mais c'est **FAUX** :P , l'ensemble des conteneurs créer sont conservé sur disque . Comme j'ai 2 Téra de disque j'ai jamais constaté le problème et comme le système partage les couches ( __layers__ ) ça ne prend pas beaucoup de disque .. 

De plus j'avais configurer mon système __Jenkins__ pour qu'il démarre un conteneur au 5 minutes :D , bien entendu un conteneur avec un nom aléatoire :D. C'est la source de mon problème !!

Regardons le nom de conteneur pour mon image utilisé par __jenkins__ : 

```bash
$ docker ps -a | grep  "x3-jenkins-tache" | wc -l 
10440
$ docker ps -a  | wc -l                                                                                                                              
10535

$ bc -l
10535 - 10440
95
```

Donc juste pour les conteneurs de la tâche __jenkins__ j'ai **10440**.

* Donc sur les 10535 seulement 95  sont potentiellement valide , So CLEANUP

```bash
$ docker rm  $(docker ps -a | grep  "x3-jenkins-tache" | cut -d " " -f 1 )                                                                                
a49875af396a
ace6514f87a9
```

* Comme on est dans le processus de ménage autant le faire complètement 

```bash
$ docker ps -a | egrep -v 'prefix1|prefix2|prefix3' | wc -l
64
```

```bash
$ docker rm $(docker ps -a | egrep -v 'prefix1|prefix2|prefix3' | cut -d " " -f 1) 
d1c8abcfd297
700f615592a4

```

* Résultat après le nettoyage des conteneurs

```bash
$ docker ps -a | wc -l
32
```

* Analyse du temps requis maintenant pour le démarrage de docker

```bash
$  docker ps -a |  wc -l && date && sudo systemctl stop docker.service && date && sudo systemctl  start docker.service && date 
32
Mon May 15 20:35:01 EDT 2017
Mon May 15 20:35:15 EDT 2017
Mon May 15 20:35:33 EDT 2017
```

* **SUCCESS** donc nous sommes passé de 13 à 20 minutes pour le démarrage à 18 seconde :D

