
# Description

Bon après avoir mis à jour mon système d'exploitation, je me dis autant mettre à jour le service Docker , car je suis encore à la version 1.12.1 alors que la nouvelle monture **docker-ce** version 17.X est disponible . En fait je veux surtout la fonctionnalité de nettoyage introduit dans la version 1.13 , avec la commande **docker prune** , mais bon autant passer directement à la derniers disponible.

Visualisation de la documentation pour réaliser la mise à jour : [https://docs.docker.com/engine/installation/linux/ubuntu/](https://docs.docker.com/engine/installation/linux/ubuntu/) 

* Point critique :
    * Suppression de l'installation courante de docker ... __isshh__
    * Mention que le contenu dans __/var/lib/docker__ ne sera pas touché ... Oui mais inquiétude
    * J'ai des __Pets__ conteneurs quelle sera le comportement ??


# Réalisation de l'opération

1. Uninstall old versions

    * Information actuellement sur la machine :

        ```
        $ dpkg -l | grep docker
        ii  docker-compose                       1.8.0-2~16.04.1                            all          Punctual, lightweight development environments using Docker
        ii  docker-engine                        1.12.1-0~xenial                            amd64        Docker: the open-source application container engine
        ii  python-docker                        1.9.0-1~16.04.1                            all          Python wrapper to access docker.io's control socket
        ii  python-dockerpty                     0.4.1-1~16.04.1                            all          Pseudo-tty handler for docker Python client (Python 2.x)

        ```

    * Version de docker :

        ```
        $ docker info
        Containers: 5569
         Running: 12
         Paused: 0
         Stopped: 5557
        Images: 201
        Server Version: 1.12.1
        Storage Driver: aufs
         Root Dir: /var/lib/docker/aufs
         Backing Filesystem: extfs
         Dirs: 11488
         Dirperm1 Supported: true
        Logging Driver: json-file
        Cgroup Driver: cgroupfs
        Plugins:
         Volume: local
         Network: bridge null host overlay
        Swarm: inactive
        Runtimes: runc
        Default Runtime: runc
        Security Options: apparmor seccomp
        Kernel Version: 4.4.0-77-generic
        Operating System: Ubuntu 16.04.2 LTS
        OSType: linux
        Architecture: x86_64
        CPUs: 8
        Total Memory: 15.66 GiB
        Name: PROD.x3rus.com
        ID: XSBL:FA3U:SHFP:ALQL:3KBM:AO2P:HAJH:QWEI:QKGY:TU2P:6EU5:JT62
        Docker Root Dir: /var/lib/docker
        Debug Mode (client): false
        Debug Mode (server): false
        Registry: https://index.docker.io/v1/
        WARNING: No swap limit support
        Insecure Registries:
         127.0.0.0/8
        ```

    * Backup des PET container [bk\_pet\_container.sh](./bk_pet_container.sh), création des images avec le mot __running__
        Exemple de l'opération réaliser par le script .

        ```bash
        $ docker ps | grep mypetconteneur
        6834c5d92038        mypetconteneur                    "/root/run.sh"           8 months ago        Up 21 hours                  25/tcp                                                                                                    
        $ docker commit 6834c5d92038 mypetconteneur:running
        sha256:5fa6438ca8757507384e16d6f8edabe9dc940614d8573800cf9d312f94faa78d

        ٩(◠◡◠)۶ $ docker images | grep mypetconteneur
        mypetconteneur                          running             5fa6438ca875        10 seconds ago      312.8 MB
        mypetconteneur                          latest              eb5dbfd61c56        8 months ago        184 MB
        ```

    * Backup du répertoire /var/lib/docker 

        ```bash
        $ sudo du -hs docker/                                                                                                                                                                 
        20G     docker/
        $ sudo cp -a  docker/ docker-1.12.1-bk-$(date +%F)

        ```

    * En commentaire le __repository__ docker (__/etc/apt/sources.list.d/docker.list__)

    * Opération requise 

        ```
        $ sudo apt-get remove docker docker-engine
        0 upgraded, 0 newly installed, 1 to remove and 0 not upgraded.
        After this operation, 102 MB disk space will be freed.
        Do you want to continue? [Y/n] y

        ```

    * Note : **The contents of /var/lib/docker/, including images, containers, volumes, and networks, are preserved.**

2. Configuration du __repository__ 

    ```bash
    $ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
    ``` 

3. Ajout de la clé __GPG__ du __repository__

    ```bash
    $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    ```

4. Configuration du __repository stable__

    ```bash
    $ sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
    ```

4. Validation de la disponibilité 

    ```bash
    $ apt-cache madison docker-ce
    docker-ce | 17.03.1~ce-0~ubuntu-xenial | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
    docker-ce | 17.03.0~ce-0~ubuntu-xenial | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
    ```

5. Installation

    ```bash
    $ apt-cache madison docker-ce
    docker-ce | 17.03.1~ce-0~ubuntu-xenial | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages
    docker-ce | 17.03.0~ce-0~ubuntu-xenial | https://download.docker.com/linux/ubuntu xenial/stable amd64 Packages

    
    $ sudo apt-get install docker-ce=17.03.1~ce-0~ubuntu-xenial
    Configuration file '/etc/default/docker'
    ==> Modified (by you or by a script) since installation.
    ==> Package distributor has shipped an updated version.
    ==> Keeping old config file as default.
    Installing new version of config file /etc/init.d/docker ...
    Installing new version of config file /etc/init/docker.conf ... 
    ```

6. Valider que le __device mapper__ est TOUJOURS **AUFS** et non **devicemapper** ([https://docs.docker.com/engine/userguide/storagedriver/selectadriver/](https://docs.docker.com/engine/userguide/storagedriver/selectadriver/)


# Résultat 

```bash

$ sudo systemctl status docker.service                                                                                                                                               
● docker.service - Docker Application Container Engine
   Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
  Drop-In: /etc/systemd/system/docker.service.d
           └─service-overrides.conf
   Active: active (running) since Mon 2017-05-15 21:14:30 EDT; 45s ago
     Docs: https://docs.docker.com
 Main PID: 13231 (dockerd)
   CGroup: /system.slice/docker.service

$ docker ps
```

**TOUT EST BON**

```bash
$ docker info
Containers: 31
 Running: 12
 Paused: 0
 Stopped: 19
Images: 215
Server Version: 17.05.0-ce
Storage Driver: aufs
 Root Dir: /var/lib/docker/aufs
 Backing Filesystem: extfs
 Dirs: 427
 Dirperm1 Supported: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins: 
 Volume: local
 Network: bridge host macvlan null overlay
Swarm: inactive
Runtimes: runc
Default Runtime: runc
Init Binary: docker-init
containerd version: 9048e5e50717ea4497b757314bad98ea3763c145
runc version: 9c2d8d184e5da67c95d601382adf14862e4f2228
init version: 949e6fa
Security Options:
 apparmor
 seccomp
  Profile: default
Kernel Version: 4.4.0-77-generic
Operating System: Ubuntu 16.04.2 LTS
OSType: linux
Architecture: x86_64
CPUs: 8
Total Memory: 15.66GiB
Name: PROD.x3rus.com
ID: XSBL:FA3U:SHFP:ALQL:3KBM:AO2P:HAJH:QWEI:QKGY:TU2P:6EU5:JT62
Docker Root Dir: /var/lib/docker
Debug Mode (client): false
Debug Mode (server): false
Registry: https://index.docker.io/v1/
Experimental: false
Insecure Registries:
 127.0.0.0/8
Live Restore Enabled: false

WARNING: No swap limit support

```
