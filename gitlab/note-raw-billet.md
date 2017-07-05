# Description 

Mise en place d'une strategie de backup pour gitlab

L'installation original de gitlab n'inclut pas la sauvegarde ... important de le mettre en place . 

Billet : config/goishi#1 

# Opérations 

* Recherche sur internet de lien sur l'opération
    * https://docs.gitlab.com/omnibus/settings/backups.html
    * https://docs.gitlab.com/omnibus/settings/backups.html#creating-backups-for-gitlab-instances-in-docker-containers : Création manuel du backup
    * https://docs.gitlab.com/omnibus/settings/backups.html#creating-an-application-backup : Semble être la meillleur définition 
    * https://docs.gitlab.com/ce/raketasks/backup_restore.html#uploading-backups-to-a-remote-cloud-storage : pour upload clouda
    * https://docs.gitlab.com/ce/raketasks/backup_restore.html#backup-archive-permissions: permission


* Bon j'ai tous je pense...

* Modification du docker-compose pour avoir les variables :

```
  gitlab_rails['manage_backup_path'] = true
  gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
  gitlab_rails['backup_archive_permissions'] = 0640
  gitlab_rails['backup_keep_time'] = 604800

```

* arrêt et redémarrage conteneur ..  ( note pour la formation , même si j'ai éteint le conteneur avec le wiki comme il est off-line je continue ma documentation :D ) 

```bash
$ docker-compose stop 
Stopping x3-gitlab-f ... done

$ docker-compose up 
Recreating x3-gitlab-f
Attaching to x3-gitlab-f
x3-gitlab-f | Thank you for using GitLab Docker Image!
x3-gitlab-f | Current version: gitlab-ce=9.2.5-ce.0

``` 

* L'application est revnu , test de backup manuel , comme j'avais le lien en haut directement dans ma document go .

```bash
$ docker ps
CONTAINER ID        IMAGE                     COMMAND             CREATED             STATUS                   PORTS                     NAMES
190528be4caf        gitlab/gitlab-ce:latest   "/assets/wrapper"   7 minutes ago       Up 7 minutes (healthy)   22/tcp, 80/tcp, 443/tcp   x3-gitlab-f

$ docker exec -t x3-gitlab-f gitlab-rake gitlab:backup:create

Dumping database ... 
Dumping PostgreSQL database gitlabhq_production ... [DONE]
done
Dumping repositories ...
 * sysadmin/dockers ... [DONE]
 * sysadmin/dockers.wiki ...  [SKIPPED]
 * sysadmin/scripts ... [SKIPPED]
[ .... ]
```

* Super maintenant validation demain matin que le backup fut bien automatiquement généré pendant la nuit 
