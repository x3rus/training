# description 

Pour ceux qui n'ont pas constaté le problème t'en mieux pour les autres désolé :) , malheureusement je ne peux pas garantir la disponibilité en tous temps de mon site :-/. Comme souvent mentionné ceci est sur une base volontaire, je ne peux négligé mon travail pour les formations réalisé bénévolement. De plus je ne négligerai pas ma vie familial pour rien au monde :) .

Mais je fais de mon mieux pour jonglé avec l'ensemble de mon mieux pour assurer une disponibilité . Pour information le site fut non disponible du Vendredi soir au Jeudi soir , le temps de comprendre l'ensemble de la problématique et de prendre l'action requise.

Est-ce que j'aurais pu corriger le problème plus tôt ? Probablement , est-ce que je l'aurait aussi bien compris que maintenant assurément pas :D !

Bon revenons au problème ... 

Suite à la réalisation de la mise à jour sur le serveur de "Production", j'ai réalisé un redémarrage du serveur , lorsque le serveur est revenue , après 25 minutes d'attente le service docker est revenu . Voir le document [02-performance-multi-conteneur.md](./02-performance-multi-conteneur.md) pour la raison de ce délais.

Une fois l'ensemble revenu le conteneur de **proxy** n'était PAS démarré . À quoi sert mon __proxy__ voici une représentation graphique de la configuration avec l'interconnexion entre les modules ..

![](./imgs/schema-proxy.png)

Donc le __proxy__ me permet d'avoir une adresse IP publique qui offre plusieurs site web qui sont dans plusieurs conteneurs . Cette configuration est requis car je ne peux pas avoir plusieurs conteneur qui se __bind__ qui s'accroche à la même IP pour le même Port.
Malheureusement même si l'ensemble des conteneurs des sites web fonctionne j'ai un d'entré unique "problématique".

# État du problème 

* Visualisation des conteneurs actif :

```bash
$ docker ps | grep proxy
[ RIEN ]
```

* Voici ce qui se passe quand j'essaye de démarrer le conteneur :

```bash
$ docker start proxy
ERROR: for x3-proxy  Cannot start service x3-proxy: b'driver failed programming external connectivity on endpoint proxy (e2dd51112c09fb199607fc7fc3e06a90576a27db44ebe6771898a3a26f443b64): Bind for 192.99.13.211:443 failed: port is already allocated'
ERROR: Encountered errors while bringing up the project.

```

* Bizarre car le port devrais justement être pris par lui 

* Qui utilise le port ??

```bash
$ sudo netstat -lntp | grep 443
tcp        0      0 192.99.87.212:443       0.0.0.0:*               LISTEN      7074/docker-proxy
tcp        0      0 192.99.87.212:8443      0.0.0.0:*               LISTEN      7063/docker-proxy
tcp        0      0 192.99.13.211:443       0.0.0.0:*               LISTEN      4452/docker-proxy

```

```bash
$ ps aux | grep 4452
root      4452  0.0  0.0 109176  3832 ?        Sl   May13   0:00 /usr/bin/docker-proxy -proto tcp -host-ip 192.99.13.211 -host-port 443 -container-ip 172.42.0.2 -container-port 443
```

* Exemple de contenu de conteneur ... Pour la recherche de __l'ip__ 172.42.0.2

```bash
root@PROD:/var/lib/docker/containers# cat ffeeb78006d54745e22f466e78a46e67ba36fae2a4fc5f6e0ceabd06b42ab15a/hosts 
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
172.17.0.5      ffeeb78006d5
```

* Un gros __find__ de la mort pour trouver le conteneur "coupable" qui aurait l'IP 172.42.0.2

    ```bash
root@PROD:/var/lib/docker/containers# find -type f -name "hosts" -exec grep -H "172.42.0.2" {} \;                                                                                        
./8efe40d2b2e00360398e156f3b7de97d11cb6bf45ea4b050f290092b22f4c802/hosts:172.42.0.2     proxy.x3rus.com proxy
```

* Bon l'IP est bien pris par le conteneur __docker__ pourquoi il démarre pas :-/

* Bon on force le **stop** 

```bash
root@PROD:/var/lib/docker/containers/8efe40d2b2e00360398e156f3b7de97d11cb6bf45ea4b050f290092b22f4c802# docker ps -a | grep prox
8efe40d2b2e0        httpd                             "httpd-foreground"       3 months ago        Exited (128) 39 hours ago                                                                                                                                                                                proxy
root@PROD:/var/lib/docker/containers/8efe40d2b2e00360398e156f3b7de97d11cb6bf45ea4b050f290092b22f4c802# docker stop 8efe40d2b2e0
8efe40d2b2e0
root@PROD:/var/lib/docker/containers/8efe40d2b2e00360398e156f3b7de97d11cb6bf45ea4b050f290092b22f4c802# echo $?
0
```

* On  refait un **start**
```bash
root@PROD:/var/lib/docker/containers/8efe40d2b2e00360398e156f3b7de97d11cb6bf45ea4b050f290092b22f4c802# docker start proxy 
Error response from daemon: driver failed programming external connectivity on endpoint proxy (2ba0f561ed7f3a37fc0b003cc8bf1ea2b221a48a2bd9f8edc22ac43754c119d0): Bind for 192.99.13.211:443 failed: port is already allocated
Error: failed to start containers: proxy

```

* Pas mieux ...

* On tue les __docker-proxy__ et on démarre le __proxy__ 

```bash
root@PROD:/var/lib/docker# ps aux | grep 172.42.0.2
root      4452  0.0  0.0 109176  3348 ?        Sl   May13   0:00 /usr/bin/docker-proxy -proto tcp -host-ip 192.99.13.211 -host-port 443 -container-ip 172.42.0.2 -container-port 443
root      4460  0.0  0.0 109176  4892 ?        Sl   May13   0:00 /usr/bin/docker-proxy -proto tcp -host-ip 192.99.13.211 -host-port 80 -container-ip 172.42.0.2 -container-port 80
root     12862  0.0  0.0  16364  2500 pts/2    S+   14:00   0:00 grep --color=auto 172.42.0.2
root@PROD:/var/lib/docker# kill 4452 4460

root@PROD:/var/lib/docker# docker start proxy
Error response from daemon: driver failed programming external connectivity on endpoint proxy (6231c85dbb4a96701e5907f0fa4d683fbf5d73eeb8655447a207d420f648b8d2): Bind for 192.99.13.211:443 failed: port is already allocated
Error: failed to start containers: proxy
```

* Destruction du conteneur , ce n'est PAS un __Pet__ conteneur donc pas de problème "normalement" :P .

```bash
$ docker ps -a | grep proxy
8efe40d2b2e0        httpd                             "httpd-foreground"       3 months ago        Exited (128) 45 hours ago                                                                                                                                                                             proxy

$ docker rm 8efe40d2b2e0
8efe40d2b2e0

```

* Redémarrage après destruction ... so 10 minutes?

```bash
$ date && sudo systemctl stop docker.service                                                                                                          
$ date && sudo systemctl start docker.service                                                                                                        
```

* **FUCK** toujours la :-/, port ouvert PAS le même __PID__ même IP !!

```bash
$ sudo netstat -lntp | grep 443
tcp        0      0 192.99.87.212:443       0.0.0.0:*               LISTEN      14663/docker-proxy
tcp        0      0 192.99.87.212:8443      0.0.0.0:*               LISTEN      14652/docker-proxy
tcp        0      0 192.99.13.211:443       0.0.0.0:*               LISTEN      10996/docker-proxy
$ ps aux | grep 10996
root     10996  0.0  0.0 109176  5356 ?        Sl   20:12   0:00 /usr/bin/docker-proxy -proto tcp -host-ip 192.99.13.211 -host-port 443 -container-ip 172.42.0.2 -container-port 443

```

# Recherche sur Internet de la cause 

* La recherche fut difficile car plusieurs personne rapport ce genre de problème, mais uniquement parce qu'ils ont un processus qui écoute sur le port. Voici la meilleur explication que j'ai trouvé :

https://github.com/moby/moby/issues/25981 clairement le problème (aboch commented on Oct 18, 2016 )

> This issue is a side-effect of the changes added to support the --live-restore feature.
> 
> From docker 1.12.0 onward, when the bridge network driver comes up, it will restores the bridge network endpoints it finds in the store.
> While doing this, it also restores the port bindings associated with the endpoint, if any.
> 
> Note:
> 
>     Under normal condition at daemon boot, no endpoints are present in the store.
>     If stale endpoints are present (this is usually the case of an ungraceful shutdown of the daemon with running containers), they are expected to be removed during boot as part of the stale sandbox cleanup process run by libnetwork core.
>     If endpoints are present because of the live-restore, they will not be removed because the sandbox cleanup will not happen for the containers which are running.
> 
> The issue seems like the sandbox for stale endpoints from older docker version run is not present, therefore libnetwork core does not invoke the cleanup of the stale endpoints with the driver.
> 
> I believe the stale endpoints issue can be fixed by removing the networks and restarting the daemon. Because during the bridge endpoint restore, the endpoint is discarded and removed from store if the corresponding network is missing.
> 
> If the above does not work, one solution is to manually remove the problematic docker/network/v1.0/bridge-endpoint/<id> key value from the store. I just found out this cli tool to browse and modify a boltdb store, but did not have much luck using it so far (https://github.com/br0xen/boltbrowser).
> 
> Otherwise, last resort is to remove the /var/lib/docker/network/files/local-kv.db file, before starting the daemon.
> 
> On a side note, there is also a bug which will cause this issue. It is explained and fixed in docker/libnetwork#1504 and will be available in next release.


Le problème concorde et l'explication permet d'avoir confiance à la problématique ... Essayons l'opération !

# Réalisation du correctif 

* Suppression du réseau 

```bash
$ docker network inspect br-x3 > docker-inspect-br-x3-$(date +%F)
```

```bash
$ cat docker-inspect-br-x3-2017-05-17  | egrep 'Name|IPv4A'
        "Name": "br-x3",
                "Name": "cadvisor",
                "IPv4Address": "172.42.0.6/24",
                "Name": "exporter",
                "IPv4Address": "172.42.0.4/24",
                "Name": "cms",
                "IPv4Address": "172.42.0.9/24",
                "Name": "grafana",
                "IPv4Address": "172.42.0.3/24",
                "Name": "prometheus",
                "IPv4Address": "172.42.0.10/24",
                "Name": "mysql",
                "IPv4Address": "172.42.0.13/24",
```


* Arrêt des conteneurs 

```bash
$ docker stop $(cat docker-inspect-br-x3-2017-05-17  | egrep 'Name' | cut -d ":" -f 2 | tr -d '"' | tr -d ',' | grep -v br-x3)
```

* Backup manuelle des __Pet conteneurs__ , car j'avais un peu de stress que le conteneur "Actif / Initialisé" , ne redémarre pas . Certain système n'utilise pas le nom "humain" pour initialisé leur environnement mais des ID unique généré lors de la création de la configuration. Donc pour pas prendre de risque

```bash
$ docker commit 6834c5d92038 mail-relay:running17
$ docker commit eb229bbf1b51 mysql:running17
```

* Suppression du réseau problématique

```bash
$ docker network rm br-x3
```

* Redémarrage du service

```bash
$ sudo systemctl stop docker.service
$ sudo systemctl start docker.service
$ sudo journalctl -u docker.service > log-docker-service-$(date +%F)
```
[log-docker-service-$(date +%F)](./log-docker-service-2017-05-17)

> Erreur de démarrage conteneur car manque network br-x3
> May 17 21:28:23 PROD.x3rus.com docker[20583]: time="2017-05-17T21:28:23.994291509-04:00" level=error msg="Failed to start container 747ecf7fd0ecbc2e34be41426908be3e398b2ab36d5b8361d153d7f577751754: network br-x3 not found"

* visualisation état 

```bash
$ docker ps 
CONTAINER ID        IMAGE                     COMMAND             CREATED             STATUS                        PORTS                                                                                                          NAMES
1da346e53eb8        gitlab/gitlab-ce:latest   "/assets/wrapper"   7 days ago          Up About a minute (healthy)               gitlab
6834c5d92038        x3-mail-relay             "/root/run.sh"      8 months ago        Up About a minute             25/tcp                                                                                                         mailrelay
``` 

* Création du réseau 

```bash
$ docker network create -d bridge --subnet=172.42.0.0/24 br-x3
eabb9428a2dc43af4f5a693fa8b08f840784a9be5b43c5320d56cd8ab7b5733a
```  

* Validation que ça fonctionne , réalisation d'un teste passant , redémarrage d'un conteneur __prometheus__

```bash
$ docker start prometheus
$ docker ps | grep cm-prometh
87e80ea63376        prom/prometheus           "/bin/prometheus -..."   2 months ago        Up 9 seconds             9090/tcp                                                                                                       prometheus
$ docker network inspect br-x3 > inspect-br-x3-cm-prometheus-p
```
[inspect-br-x3-cm-prometheus-p](./inspect-br-x3-cm-prometheus-p)


* Arrêt service docker 

```bash
$ sudo systemctl stop docker.service
$ sudo systemctl start docker.service
```

* Logs, **PAS** d'erreur

```bash
$ sudo journalctl -u docker.service > log-docker-service-$(date +%F)-2
```

* Validation pour docker __proxy__

```bash
$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS                             PORTS                                                                                                                                                                    NAMES
0ea5af3c7861        httpd                            "httpd-foreground"       3 days ago          Up About a minute                  192.99.13.211:80->80/tcp, 192.99.13.211:443->443/tcp                                                                                                                     proxy

```

**SUCCESS** :D
