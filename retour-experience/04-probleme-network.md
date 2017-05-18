# Description 

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
root      4452  0.0  0.0 109176  3832 ?        Sl   May13   0:00 /usr/bin/docker-proxy -proto tcp -host-ip 192.99.13.211 -host-port 443 -container-ip 172.24.0.2 -container-port 443
```

* Exemple de contenu de conteneur ... Pour la recherche de __l'ip__ 172.24.0.2

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

* Un gros __find__ de la mort pour trouver le conteneur "coupable" qui aurait l'IP 172.24.0.2

    ```bash
root@PROD:/var/lib/docker/containers# find -type f -name "hosts" -exec grep -H "172.24.0.2" {} \;                                                                                        
./8efe40d2b2e00360398e156f3b7de97d11cb6bf45ea4b050f290092b22f4c802/hosts:172.24.0.2     proxy.x3rus.com proxy
```

* Bon l'IP est bien pris par le conteneur __docker__ pourquoi il par pas :-/

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
root@PROD:/var/lib/docker# ps aux | grep 172.24.0.2
root      4452  0.0  0.0 109176  3348 ?        Sl   May13   0:00 /usr/bin/docker-proxy -proto tcp -host-ip 192.99.13.211 -host-port 443 -container-ip 172.24.0.2 -container-port 443
root      4460  0.0  0.0 109176  4892 ?        Sl   May13   0:00 /usr/bin/docker-proxy -proto tcp -host-ip 192.99.13.211 -host-port 80 -container-ip 172.24.0.2 -container-port 80
root     12862  0.0  0.0  16364  2500 pts/2    S+   14:00   0:00 grep --color=auto 172.24.0.2
root@PROD:/var/lib/docker# kill 4452 4460


root@PROD:/var/lib/docker# docker start proxy
Error response from daemon: driver failed programming external connectivity on endpoint proxy (6231c85dbb4a96701e5907f0fa4d683fbf5d73eeb8655447a207d420f648b8d2): Bind for 192.99.13.211:443 failed: port is already allocated
Error: failed to start containers: proxy

```




