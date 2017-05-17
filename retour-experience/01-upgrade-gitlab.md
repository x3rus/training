
# Description 

Voici un retour d'expérience lors de mon désire de mettre à jour ma version docker de __gitlab__ ([https://about.gitlab.com/](https://about.gitlab.com/) !

Je suis un grand utilisateur de __gitlab__, l'ensemble de mes tâches , documentation et bien entendu mes dépôts de code et configuration sont dans ce système. En d'autre mot l'indisponibilité du service est "critique" pour moi , presque qu'au même titre que mes courriels. Pour ceux qui l'on constaté mon site web lui est moins critique , ça fait 3 jours qu'il n'est plus disponible :P.

Actuellement mes instances __gitlab__ fonctionne grâce à un docker disponible sur [hub.docker.com](https://hub.docker.com/r/gitlab/gitlab-ce/), comme vous pouvez le voir ce n'est PAS un docker officiel, cependant ce dernier fut réalisé par la compagnie __gitlab__ donc valide ! 

Voici les étapes couvert :

1. Validation de mes sauvegardes
2. Réalisation de la mise à jours.

2 étapes simple à écrire nous constaterons que l'opération fut un peu plus longue :D.

## Mise en contexte 

Version en production : 8.11.4
Version disponible : 9.1.3

Comme vous pouvez le voir il y a de nombreuse version et il y a changement de version majeur !! 

Serveur de production : **PROD**
Serveur de test : **TEST**

# Validation de mes sauvegardes

Je réalise une sauvegarde journalier de l'environnement , malheureusement je n'ai jamais valider ma sauvegarde , c'était une opération planifier, mais non priorité ! Avant la mise à jour ceci s'imposait !!

1. Récupération du backup

    ```bash
    TEST $ scp PROD.x3rus.com:./1494152736_gitlab_backup.tar .
    TEST $ scp PROD.x3rus.com:./git-lab-docker-compose.yml ./docker-compose.yml
    ```

2. Mise à jour l'image __gitlab-ce__ sur **TEST**  (Première erreur lors de la réalisation de la procédure :D )

    ```bash
    TEST $ docker pull gitlab/gitlab-ce
    Using default tag: latest
    latest: Pulling from gitlab/gitlab-ce
    aafe6b5e13de: Pull complete 
    0a2b43a72660: Pull complete 
    18bdd1e546d2: Pull complete 
    ```

3. Site web __gitlab__ dit : ["You can only restore a backup to exactly the same version of GitLab on which it was created. The best way to migrate your repositories from one server to another is through backup restore. "](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/raketasks/backup_restore.md)

4. Pas de problème, je tente de récupérer l'image de __gitlab/gitlab-ce:8.11.4__ sur le site [hub.docker.com](https//hub.docker.com)

    Pas de chance cette version n'est plus disponible !!! Voici les version disponible : [https://hub.docker.com/r/gitlab/gitlab-ce/tags/](https://hub.docker.com/r/gitlab/gitlab-ce/tags/). Résultat Comment puis valider mon backup alors que la version doit être équivalente !! En fait , l'image est ENCORE disponible sur le serveur de production **PROD** c'est celle la qui est en utilisation. Attention, je parle bien de l'image et NON du conteneur en exécution . Nous allons donc récupérer l'image sur le serveur de production et la ramener sur l'environnement de **TEST**.

5. Récupération de l'image actuellement en opération vers **TEST**

    ```bash
    PROD $  docker images | grep gitlab
    gitlab/gitlab-ce                       latest              a147e6c36458        8 months ago        1.205 GB
    PROD $ docker save -o gitlab-ce:8.4.11.tar gitlab/gitlab-ce:latest
    PROD $ gzip gitlab-ce\:8.4.11.tar
    ```
    
    ```bash
    TEST $ scp PROD.x3rus.com:./gitlab-ce:8.4.11.tar.gz .
    TEST $ docker load -i gitlab-ce\:8.4.11.tar 
    The image gitlab/gitlab-ce:latest already exists, renaming the old one with ID sha256:9eacf3c0aeecffaf8201f3d2a65fa910f3d35cb5a260e0c08d242734456e0d0d to empty string
    Loaded image: gitlab/gitlab-ce:latest
    TEST $ docker images | grep git
    gitlab/gitlab-ce                 <none>              9eacf3c0aeec        2 days ago          1.1GB
    gitlab/gitlab-ce                 latest              a147e6c36458        8 months ago        1.21GB
    ```
    
    Lors de l'extraction de l'image le système conserve le nom , ici nous avons donc l'image __gitlab/gitlab-ce:latest__ qui désire être chargé , mais nous avons déjà mis à jour l'image __gitlab__ avec la dernière version , voila pourquoi nous avons "l'erreur".

    Afin d'avoir un nommage convenable , je vais modifier les nom des images pour avoir la bonne nomenclature.

    ```bash
    TEST $ docker tag a147e6c36458 gitlab/gitlab-ce:8.4.11
    TEST $ docker tag 9eacf3c0aeec gitlab/gitlab-ce:9.1.3
    TEST $ docker tag 9eacf3c0aeec gitlab/gitlab-ce:latest
    TEST $ docker images | grep gitlab 
    gitlab/gitlab-ce                 9.1.3               9eacf3c0aeec        2 days ago          1.1GB
    gitlab/gitlab-ce                 latest              9eacf3c0aeec        2 days ago          1.1GB
    gitlab/gitlab-ce                 8.4.11              a147e6c36458        8 months ago        1.21GB
    ```

    Apprentissage de ce problème : FAUT avoir à l'interne un __docker registry__ pour conserver nos images !!! 

6. Démarrage de l'image avec le __docker-compose.yml__ de production (quelques modification principalement pour la question de port et IP )

    Démarrage de l'instance ... Malheureusement il y a un problème avec un certificat, j'ai pas envie de me prendre la tête puis en faire un __self-sign__ , je reprends le répertoire __/etc/__ dans le volume du docker . Après tous c'est principalement la mise à jour que je veux valider :D .

    ```bash
    TEST $  docker-compose up cm-gitlab
    [... OUTPUT COUPÉ ... ]
    cm-gitlab-t  | ==> /var/log/gitlab/nginx/error.log <==
    cm-gitlab-t  | 2017/05/08 00:42:14 [emerg] 626#0: BIO_new_file("/etc/gitlab/ssl/PROD.x3rus.com.crt") failed (SSL: error:02001002:system library:fopen:No such file or directory:fopen('/etc/gitlab/ssl/PROD.x3rus.com.crt','r') error:2006D080:BIO routines:BIO_new_file:no such file)
    TEST$ mkdir etc_gitlab_prod
    
    PROD $ du -hs /volumes/gitlab/gitlab/etc/
    PROD $ sudo cp -r /volumes/gitlab/gitlab/etc/ etc_gitlab
    PROD $ sudo tar -zcvf etc_gitlab.tar.gz etc_gitlab/
    
    TEST $ scp PROD.x3rus.com:./etc_gitlab.tar.gz .
    TEST $ sudo tar -zxvf etc_gitlab.tar.gz
    TEST $ cd etc_gitlab
    TEST $ sudo cp -r * /srv/docker/gitlab-t/gitlab/etc/
    TEST $  docker-compose up cm-gitlab
    ```

**SUCCESS** , le système me demande de définir un mot de passe administrateur :D !!


## Restauration de la sauvegarde 

Référence : [doc Gitlab](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/raketasks/backup_restore.md#restore-for-omnibus-installations)

* Tous sur **TEST**

1. réalisation d'une __re-configuration__ afin de m'assurer qu'il n'y a pas de problème 

    ```bash 
    $ docker exec -it cm-gitlab-t  gitlab-ctl reconfigure
    $ echo $?
    0
    ```

2. Validation où je dois mettre mon fichier de sauvegarde pour la restauration :P  

    ```bash
    $ docker exec -it cm-gitlab-t  grep 'backup_path' /etc/gitlab/gitlab.rb
    # gitlab_rails['manage_backup_path'] = true
    # gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
    $ grep "/var/opt/gitlab" docker-compose.yml
    $ grep "/var/opt/gitlab" docker-compose.yml
                gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
            - '/srv/docker/gitlab-t/gitlab/data/:/var/opt/gitlab'
    
    $ sudo cp 1494152736_gitlab_backup.tar /srv/docker/gitlab-t/gitlab/data/backups/
    ```

* Début de la restauration 

    ```bash
    $ docker exec -it cm-gitlab-t   gitlab-ctl stop unicorn 
    $ docker exec -it cm-gitlab-t   gitlab-ctl stop sidekiq
    $ docker exec -it cm-gitlab-t   gitlab-ctl status
    run: gitlab-workhorse: (pid 333) 1102s; run: log: (pid 299) 1109s
    run: logrotate: (pid 314) 1105s; run: log: (pid 313) 1105s
    run: nginx: (pid 307) 1107s; run: log: (pid 306) 1107s
    run: postgresql: (pid 218) 1117s; run: log: (pid 217) 1117s
    run: redis: (pid 198) 1119s; run: log: (pid 197) 1119s
    run: registry: (pid 321) 1103s; run: log: (pid 320) 1103s
    down: sidekiq: 25s, normally up; run: log: (pid 289) 1110s
    down: unicorn: 35s, normally up; run: log: (pid 270) 1111s

    $ docker exec -it cm-gitlab-t   gitlab-rake gitlab:backup:restore BACKUP=1494152736
    Unpacking backup ... tar: 1494152736_gitlab_backup.tar: Cannot open: Permission denied
    tar: Error is not recoverable: exiting now
    unpacking backup failed
    ```

* Problème de permission sur le répertoire ou fichier, validation et correction

    ```bash
    $ sudo ls -ld /srv/docker/cm-gitlab-t/gitlab/data/backups/
    drwx------ 2 systemd-journal-upload root 4096 May  8 21:51 /srv/docker/cm-gitlab-t/gitlab/data/backups/
    $ sudo ls -l /srv/docker/cm-gitlab-t/gitlab/data/backups/
    total 324324
    -rw-r----- 1 root root 332103680 May  8 21:51 1494152736_gitlab_backup.tar
    $ sudo chown systemd-journal-upload:root /srv/docker/cm-gitlab-t/gitlab/data/backups/1494152736_gitlab_backup.tar
    ```

* On refait une tentative 

    ```bash
    $ docker exec -it cm-gitlab-t   gitlab-rake gitlab:backup:restore BACKUP=1494152736
    
    $ docker exec -it cm-gitlab-t   gitlab-ctl start
    ok: run: gitlab-workhorse: (pid 333) 1286s
    ok: run: logrotate: (pid 314) 1289s
    ok: run: nginx: (pid 307) 1291s
    ok: run: postgresql: (pid 218) 1301s
    ok: run: redis: (pid 198) 1303s
    ok: run: registry: (pid 321) 1287s
    ok: run: sidekiq: (pid 1969) 0s
    ok: run: unicorn: (pid 1973) 1s
    $ docker exec -it cm-gitlab-t  gitlab-rake gitlab:check SANITIZE=true
    ```

**SUCCESS !!!** 

# Réalisation Mise à jour du conteneur de test

1. Arrêt du conteneur __gitlab__ en cours

    ```bash
    $ docker-compose stop cm-gitlab
    ```

2. Changement de la définition de l'image à utiliser dans le fichier  __docker-compose.yml__

    ```
    cm-gitlab:
        image: 'gitlab/gitlab-ce:latest'
        container_name : 'gitlab-t'
        hostname: PROD.x3rus.com
    ```

3. Démarrage du conteneur 

    ```bash
    $ docker-compose up cm-gitlab
    [... OUTPUT COUPÉ ...]
    cm-gitlab-t  | gitlab Reconfigured!
    Checking for an omnibus managed postgresql: OK
    Checking if we already upgraded: NOT OK
    Checking for a newer version of PostgreSQL to install: OK
    cm-gitlab-t  | Upgrading PostgreSQL to 9.6.1
    Checking if PostgreSQL bin files are symlinked to the expected location: OK
    Toggling deploy page:cp /opt/gitlab/embedded/service/gitlab-rails/public/deploy.html /opt/gitlab/embedded/service/gitlab-rails/public/index.html
    Toggling deploy page: OK
    Toggling services:ok: down: gitaly: 1s
    [ ... OUTPUT COUPÉ ...]
    cm-gitlab-t  | ok: down: gitlab-monitor: 0s, normally up
    cm-gitlab-t  | ok: down: logrotate: 1s, normally up                                                                                   
    cm-gitlab-t  | ok: down: node-exporter: 0s, normally up                                                      
    cm-gitlab-t  | ok: down: postgres-exporter: 0s, normally up
    cm-gitlab-t  | ok: down: prometheus: 1s, normally up
    cm-gitlab-t  | ok: down: redis-exporter: 0s, normally up
    cm-gitlab-t  | ok: down: registry: 0s, normally up
    cm-gitlab-t  | ok: down: sidekiq: 0s, normally up
    Toggling services: OK
    cm-gitlab-t  | Waiting 30 seconds to ensure tasks complete before PostgreSQL upgrade
    cm-gitlab-t  | Please hit Ctrl-C now if you want to cancel the upgrade
    Stopping the database:ok: down: postgresql: 1s, normally up
    Stopping the database: OK
    Update the symlinks: OK
    Creating temporary data directory: OK
    Initializing the new database: OK
    Upgrading the data: OK
    Move the old data directory out of the way: OK
    Rename the new data directory: OK
    cm-gitlab-t  | Upgrade is complete, doing post configuration steps
    Running reconfigure: OK
    cm-gitlab-t  | Database upgrade is complete, running analyze_new_cluster.sh
    cm-gitlab-t  | ==== Upgrade has completed ====
    cm-gitlab-t  | Please verify everything is working and run the following if so
    cm-gitlab-t  | rm -rf /var/opt/gitlab/postgresql/data.9.2.18
    
    [...OUTPUT COUPÉ ...]
    
    cm-gitlab-t  | ==> /var/log/gitlab/postgres-exporter/current <==
    cm-gitlab-t  | 2017-05-10_01:51:02.13266 time="2017-05-10T01:51:02Z" level=warning msg="Proceeding with outdated query maps, as the Postgres version could not be determined: Error scanning v
    ersion string: dial unix /var/opt/gitlab/postgresql/.s.PGSQL.5432: connect: no such file or directory\n" source="postgres_exporter.go:1002"
    
    ```

* Go sur la page :P __https://172.17.0.4__

    **ERROR 500**

* Wierd heu .. Pourquoi pas un redémarrage de l'application :D

    ```bash
    $ docker-compose stop cm-gitlab
    $ docker-compose up cm-gitlab

    ```

**SUCCESS**
