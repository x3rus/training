# Description integration ansible

Nous avons l'ensemble de nos ressources dans AWS , cependant soyons honnête, pour le moment ça ne sert à rien , car les instances EC2 ne sont pas configurées.

![](./imgs/architecture-overview-Network-overview-web-and-bd-ec2.png)

Nous devons donc maintenant faire la configuration des machines :

* web-terra
* bd-terra-0
* bd-terra-1

Bien entendu, nous venons de réaliser l'ensemble de la création dans AWS de manière automatique , nous n'allons pas poursuivre avec la création manuelle des configurations. Nous allons donc voir la combinaison Terraform avec Ansible. 
Ceci n'est pas une formation Ansible donc je ne vais pas prendre le temps de voir l'ensemble des configurations ansible, mais mettre l'accent sur l'intégration avec Terraform. J'essayerai un jour de faire une formation ansible... 

# Integration Ansible avec Terraform

Lors de l'utilisation de AWS avec terraform nous avons utilisé un [provider](https://www.terraform.io/docs/providers/index.html), ceci nous permet de faire la gestion des ressources , de l'infrastructure. Dans notre cas nous avons utilisé le [provider aws](https://www.terraform.io/docs/providers/aws/index.html) . 
Terraform offre un autre type,  [Provisioners](https://www.terraform.io/docs/provisioners/index.html) , ces derniers nous permettent de provisionner les machines.De réaliser des opérations avant ou après la création des ressources.

Dans notre cas, comme nous utilisons AWS , nous aurions pu faire la création d'un AMI personnalisé avec nos logiciels déjà présents, cependant nous devrions maintenir cette image dans l'ensemble des régions , l'évolution de cette dernière est pénible si nous désirons l'avoir à l'identique partout, des changements sur les instances créées dans le passé deviennent difficiles à moins de détruire et recommencer. Ce que j'aime aussi de la solution avec ansible est que je suis agnostique au choix du cloud, je peux même choisir une installation sur site.

Terraform ne supporte pas aujourd'huis nativement Ansible, mais il existe un système de [provisionner](https://www.terraform.io/docs/provisioners/index.html) qui permet d'exécuter des commandes :

* [chef](https://www.terraform.io/docs/provisioners/chef.html) : Permet de configurer l'instance à l'aide du système chef.
* [Salt-masterless](https://www.terraform.io/docs/provisioners/salt-masterless.html) : Permet de faire du provisionning à l'aide de salt, yep il manque vraiment ansible ;).
* [Connection](https://www.terraform.io/docs/provisioners/connection.html) : Permet de faire la copie d'un fichier via ssh ou winRm ( Remote pas remove :P ) 
* [File](https://www.terraform.io/docs/provisioners/file.html) : Permet de faire la copie d'un fichier d'une ressource créer , la différence ici avec le précédent et que cette méthode ne permet pas de faire la copie vers une instance autre que celle créer alors que Connection permet de définir un hostname.
* [habitat](https://www.terraform.io/docs/provisioners/habitat.html) : Permet d'exécuter l'application [habitat](https://www.habitat.sh/) créé par Chef, ceci permet de définir des services à démarrer. Je ne connais pas, malheureusement.
* [local-exec](https://www.terraform.io/docs/provisioners/local-exec.html) : Permet d'exécuter des instructions sur le serveur qui initie les instructions terraform. 
* [null_ressource](https://www.terraform.io/docs/provisioners/null_resource.html) : Ce système permet lorsque vous initialisez plusieurs instances avec l'option **count**, de regrouper les informations telles que l'ip priver , regardez l'exemple sur le site. Je vais peut-être faire un exemple, mais rien n'est sûr à l'écriture de ces lignes. 
* [remote-exec](https://www.terraform.io/docs/provisioners/remote-exec.html) : Permet d'exécuter une instruction sur l'instance initialisée, support aussi bien ssh que winrm .

Dans ma logique je vais donc faire le déploiement d'un rôle ansible pour la configuration apache. En utilisant l'instruction [local-exec](https://www.terraform.io/docs/provisioners/local-exec.html) , donc le processus utilisera l'application ansible , préalablement installée sur mon poste et le playbook aussi présent localement. 


Nous allons débuter par la configuration des bases de données , car elles sont requises pour le serveur web.


## Revue générale de notre objectif

j'aime faire un rappel rapide de l'objectif, car il y a un grand nombre de personnes qui n'ont pas lu l'ensemble du document , moi le premier je survole jusqu'a la section que je recherche :P.

Donc voici ce que nous allons faire :

![](./imgs/apps-overview-lst-configurations.png)

Nous avons 1 serveur web qui aura apache d'installé et répondra à 2 noms de domaine :

* contacts.x3rus.com
* pi.x3rus.com

Les sites web iront chercher le contenu dans une base de données :

* contact : pour le site web contacts.x3rus.com
* showpi : pour le site web pi.x3rus.com 

Les 2 serveurs de base de données sont configurés à l'identique afin de simplifier le processus de déploiement. Ils auront la base de données mysql d'installée et la configuration des 2 bases de données incluant l'import des données.


## Intro ansible "rapide" 

Bon je suis devant la machine et je me questionne, est-ce que je fais une intro ansible , oui / non ... j'avoue que je suis en questionnement. Je vais donc en faire une super rapide , afin que mes propos puissent être compris par tous !!

Information sur [ansible depuis Wikipedia](https://fr.wikipedia.org/wiki/Ansible_\(logiciel\))

> Ansible est une plate-forme logicielle libre pour la configuration et la gestion des ordinateurs. Elle combine le déploiement de logiciels multinœuds, l'exécution des tâches ad hoc, et la gestion de configuration. Elle gère les différents nœuds par-dessus SSH et ne nécessite l'installation d'aucun logiciel supplémentaire à distance sur eux. Les modules fonctionnent grâce à JSON et à la sortie standard et peuvent être écrits dans n'importe quel langage de programmation. Le système utilise YAML pour exprimer des descriptions réutilisables de systèmes.
> 
> Ansible Inc. était la société derrière le développement commercial de l'application Ansible. Red Hat rachète Ansible Inc. en octobre 2015.
> 
> Le nom Ansible a été choisi en référence au terme Ansible choisi par Ursula Le Guin dans ses romans de science-fiction pour désigner un moyen de communication plus rapide que la lumière.

Ansible pousse  les instructions via SSH .

### Ansible, les modules disponibles

Ansible vient avec une boite à outils complète composée d'un grand nombre de module : [module par catégorie](http://docs.ansible.com/ansible/latest/modules/modules_by_category.html).

Comme vous pouvez le voir, il y a un grand nombre de modules disponibles pour plusieurs types d'activités :

* Cloud modules
* Clustering modules
* Commands modules
* Crypto modules
* Database modules
* Files modules
* Identity modules
* Inventory modules
* Messaging modules
* Monitoring modules
* Net Tools modules
* Network modules
* Notification modules
* Packaging modules
* Remote Management modules
* Source Control modules
* Storage modules
* System modules
* Utilities modules
* Web Infrastructure modules
* Windows modules

Je vous laisse explorer quelques modules afin de vous mettre l'eau à la bouche , :). Bien entendu je vais en utiliser pour faire la configuration des serveurs.

### Ansible , playbook

Un [playbook](https://docs.ansible.com/ansible/2.4/ansible-playbook.html) dans ansible permet de définir une liste d'instruction qui sera réalisée sur un serveur. 
Donc pour faire le provisionnement de nos serveurs , je vais faire 2 playbook :

1. serveur web : site.yml
2. serveur de BD: db.yml

Les playbooks utiliseront une liste de rôle qui eux même utiliseront les modules pour réaliser les opérations. 

### Installation d’Ansible

Afin d'être en mesure de combiner Terreform et Ansible , tous comme vous avez du installé terraform il vous faudra Ansible :P. 

Je vous laisse le lien vers la documentation officielle : [https://docs.ansible.com/ansible/2.5/installation_guide/intro_installation.html](https://docs.ansible.com/ansible/2.5/installation_guide/intro_installation.html)

## Provisionnement des serveurs de base de données

Bon pour ceux qui me connaissent, vous savez que j'ai de la difficulté à être concis, on va dire que je vais être fidèle à moi-même encore une fois :P. On va prendre le temps de décortiquer le processus de provisionnement du serveur de Base de données incluant la partie Ansible. 

### Explication du playbook ansible

```
$ cd terraManifest/02-use-case/
$ mkdir role
$ git clone https://github.com/geerlingguy/ansible-role-mysql.git
$ mv ansible-role-mysql/ geerlingguy.mysql
```

Le module est présent nous allons maintenant définir le __playbook__ , assurez-vous d'être dans le répertoire où il y a le fichier manifeste de Terraform.
Le fichier aussi disponible du github : [bd.yml](TODO)

```
$ cd terraManifest/02-use-case/
$ cat bd.yml
 ---
- hosts: all
  become: yes
  become_user: root
  vars_files:
    - vars/mysql.yml
  roles:
    - { role: geerlingguy.mysql }
```

Prenons le temps de lire ce fichier :

* **hosts : all** : ansible nous permet d'assigner des playbooks avec un inventaire , nous permettant par exemple d'avoir une liste d'IP, nom de domaine ou autre et dire appliquent cette configuration sur ce regroupement de machines. Dans notre cas , comme nous avons des IP dynamiques dans AWS , je ne peux pas faire de filtrage , j'indique donc que ceci est applicable sur l'ensemble des hosts.
* **become: yes** : Nous allons être obligés de changé d'utilisateur pour que ce rôle fonctionne , car l'utilisateur ansible qui réalisera la connexion n'a par défaut  pas tous les droits.
* **become\_user : root** : Comme nous aurons des installations à réaliser nous devons être **root**
* **vars\_files: - vars/mysql.yml** : Ce fichier va nous permettre de lister les base de données , utilisateur , mot de passe , etc en lien avec le serveur de base de données , nous allons faire la création de ce fichier tout de suite ...
* **roles : - { role: geerlingguy.mysql }** : Ici nous réalisons l'association du rôle avec le playbook .

Vous êtes probablement allé sur la page du projet du rôle [geerlingguy.mysql](https://github.com/geerlingguy/ansible-role-mysql) , comme vous avez pu le constater, nous utilisons des variables afin de définir les bases de données a créer ainsi que les utilisateurs . Ces variables sont définies dans le fichier **vars/mysql.yml**.

Voyons le contenu :

```
mysql_root_password: super_ultime_pass
mysql_databases:
  - name: contact
    encoding: latin1
    collation: latin1_general_ci
  - name: showpi
    encoding: latin1
    collation: latin1_general_ci
mysql_users:
  - name: "contact_user"
    host: "%"
    password: "Ze_password"
    priv: "contact.*:ALL"
  - name: "pi_user"
    host: "%"
    password: "un_autre_pass"
    priv: "showpi.*:ALL"
```

Nous définissons le mot de passe de l'administrateur mysql (**root**), la création des 2 bases de données ( **contact** et **showpi**) , la création des 2 utilisateurs (**contact_user** et **pi_user**) avec les permissions adéquates. Avant d'allez plus loin essayons ceci !! Je vous priviez ça ne marche pas :P .

#### Test d'utilisation d’Ansible 

Bon on teste ça ?? :D

Pour réduire le temps de traitement je vais réduire le **count** pour n'avoir qu'UN serveur de créer , l'idée ici est de valider uniquement la commande.
Avant de faire l'intégration terraform et Ansible, je vais réaliser l'opération manuellement , donc l'enchainement ne sera pas réalisé par terraform, mais par moi avec mes petites mains :P.

```
$ terraform plan --target=aws_instance.db-terra
aws_instance.db-terra: Still creating... (10s elapsed)
aws_instance.db-terra: Still creating... (20s elapsed)
aws_instance.db-terra: Still creating... (30s elapsed)
aws_instance.db-terra: Creation complete after 40s (ID: i-000535ab086234ab0)

Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

```

À ce stade j'ai mon instance EC2 , nous sommes au même point , je vais récupérer l'adresse IP publique : 

```
$ grep "public_ip" terraform.tfstate
                            "associate_public_ip_address": "true",
                            "public_ip": "34.221.107.227",
                            "map_public_ip_on_launch": "false",
                            "map_public_ip_on_launch": "false",

```

Je double valide la connexion :

```
$ ssh -i ssh-keys/ansible-user ubuntu@34.221.107.227
ubuntu@ip-172-31-50-20:~$ sudo -l
Matching Defaults entries for ubuntu on ip-172-31-50-20.us-west-2.compute.internal:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User ubuntu may run the following commands on ip-172-31-50-20.us-west-2.compute.internal:
    (ALL : ALL) ALL
    (ALL) NOPASSWD: ALL
ubuntu@ip-172-31-50-20:~$ exit
logout
Connection to 34.221.107.227 closed.
```

Maintenant de retour sur mon laptop et je vais utiliser la commande ansible pour déployer ma configuration :

```
$ ansible-playbook -u ubuntu --ssh-common-args='-o StrictHostKeyChecking=no' -i '34.221.107.227,' --private-key ssh-keys/ansible-user -T 300 bd.yml
```

Donc j'exécute ansible-playbook  :

* **-u ubuntu** : indique que l'utilisateur pour établir la connexion est ubuntu
* **--ssh-common-args='-o StrictHostKeyChecking=no'** : Je passe un argument à SSH pour lui dire ne valide pas la clé ssh du serveur hôte
* **-i '34.221.107.227,'** : Ici attention la virgule est importante à la fin je passe donc en paramètre l'IP du serveur cible
* **--private-key ssh-keys/ansible-user** : J'indique où est la clé privé ssh
* **-T 300** : le temps du timeout 
* **bd.yml** : le fichier de playbook à exécuter.

**MALHEUREUSEMENT** : comme attendu ceci ne fonctionne pas 

```
PLAY [all] *********************************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************************
fatal: [34.221.107.227]: FAILED! => {"changed": false, "module_stderr": "Shared connection to 34.221.107.227 closed.\r\n", "module_stdout": "\r\n/bin/sh: 1: /usr/bin/python: not found\r\n", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 127}
        to retry, use: --limit @/home/xerus/git/formations/terraform/terraManifest/02-use-case/bd.retry

PLAY RECAP **********************************************************************************************************************
34.221.107.227             : ok=0    changed=0    unreachable=0    failed=1  
```

Le problème ici est que Python n'est pas installé !!!

Correction du problème 

```
$ ssh -i ssh-keys/ansible-user ubuntu@34.221.107.227
ubuntu@ip-172-31-50-20:~$ sudo apt-get -y install python
ubuntu@ip-172-31-50-20:~$ logout
Connection to 34.221.107.227 closed
```

On reprend l'ensemble : 

```
$ ansible-playbook -u ubuntu --ssh-common-args='-o StrictHostKeyChecking=no' -i '34.221.107.227,' --private-key ssh-keys/ansible-user -T 300 bd.yml
[ ... ]
TASK [geerlingguy.mysql : Define mysql_packages.] **************************************************************************************
ok: [34.221.107.227]                                                                                                                                          

TASK [geerlingguy.mysql : Define mysql_daemon.] ******************************************************************************************
ok: [34.221.107.227]    
[ ...] 

TASK [geerlingguy.mysql : Copy user-my.cnf file with password credentials.] ************************************************
skipping: [34.221.107.227]

TASK [geerlingguy.mysql : Disallow root login remotely] **********************************************************************************
ok: [34.221.107.227] => (item=DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'))

[ ...] 
TASK [geerlingguy.mysql : Ensure MySQL databases are present.] *****************************************************************
changed: [34.221.107.227] => (item={'name': 'contact', 'encoding': 'latin1', 'collation': 'latin1_general_ci'})                                              
changed: [34.221.107.227] => (item={'name': 'showpi', 'encoding': 'latin1', 'collation': 'latin1_general_ci'})  

[ ...] 
PLAY RECAP ********************************************************************************************************************
34.221.107.227             : ok=42   changed=15   unreachable=0    failed=0
```

En conclusion de notre problème pour être en mesure de faire l'enchainement Terraform -> ansible nous avons besoin d'avoir python de présent sur la machine EC2. 2 options s'offrent à nous :

1. Créer notre propre AMI qui aurait python de présent
2. Réussir à installé python , une fois la machine EC2 d initialisé.


Dans mon cas je ne veux **PAS** géré d'image __AMI__ et clairement pas uniquement pour le package **python** , donc lors de mes recherches j'ai trouvé ceci [remote-exec](https://www.terraform.io/docs/provisioners/remote-exec.html) qui permet de faire l'exécution d'une commande sur l'instance EC2 . 
J'ai donc ajouté l'instruction :

```
    provisioner "remote-exec" {
        # Install Python for Ansible
        inline = ["sudo apt-get update && sudo apt-get -y install python "]

        connection {
            type        = "ssh"
            user        = "ubuntu"
            private_key = "${file("ssh-keys/ansible-user")}"
        }
    }

```

Ceci va donc réaliser la commande **inline** pour faire la mise à jour du système d'exploitation puis faire l'installation de python. Pour ce faire il va utiliser l'utilisateur **ubunut** et la clé ssh associé **\${file("ssh-keys/ansible-user")}**.

Ceci aura aussi comme avantage de s'assurer que l'instance EC2 est disponible avant d'exécuter la commande **ansible** , en effet si vous faite d'autres commandes sur l'instance EC2 lors de l'exécution de l'instruction **local-exec** parfois l'instance EC2 est encore en cours d'initialisation, résultat la commande ne fonctionne pas :-/. 

Comme ceci n'est pas complètement automatique, on va supprimer ce que l'on ne veut pas et on va reprendre 

```
$ terraform destroy --target=aws_instance.db-terra
```

### Intégration complète avec ansible et terraform pour la BD

Donc nous avons 3 étapes pour l'intance EC2 ( je mets de côté l'ensemble du réseau ) :

1. Création de l'instance avec Terraform 
2. Configuration de l'instance pour être en mesure d'exécuter ansible **remote-exec**
3. Exécution d'ansible pour avoir l'ensemble du système entièrement configurer **local-exec**

Voici le résultat final :

```

resource "aws_instance" "db-terra" {
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.ansible.key_name}"  # assign ssh ansible key
    subnet_id = "${aws_subnet.bd-private-2a.id}"   

    associate_public_ip_address = true
   
    # Create 2 instance of the database
    count = 1

    tags {
        Name = "db${count.index}-terra"
        scope = "training"
        role = "database"
    }

    security_groups = [
        "${aws_security_group.allow_mysql_internal.id}",
        "${aws_security_group.allow_external_communication.id}",
        "${aws_security_group.allow_remote_admin.id}"
    ]

    root_block_device = {
        delete_on_termination = true
        volume_size = 20 
    }

    provisioner "remote-exec" {
        # Install Python for Ansible
         inline = ["sudo apt-get update && sudo apt-get -y install python "]

        connection {
            type        = "ssh"
            user        = "ubuntu"
            private_key = "${file("ssh-keys/ansible-user")}"
        }
    }

    provisioner "local-exec" {
        command = "ansible-playbook -u ubuntu --ssh-common-args='-o StrictHostKeyChecking=no' -i '${self.public_ip},' --private-key ssh-keys/ansible-user -T 300 bd.yml"
    }                                                                                                                                                       

} 
```


J'ai fait l'explication de l'ensemble des parties, j'espère avoir été assez claire pour l'ensemble . Je pense qu'il manque une information, j'extrais l'information de l'instance EC2 afin d'avoir l'adresse IP publique de la machine avec la variable **self.public\_ip**. Avec cette méthode l'instruction ansible sera exécutée 2 fois , soit pour chacune des instances , si j'augmente la valeur de **count** se sera autant que cette valeur.

Nous pouvons donc faire la création et voir le résultat : 

```
$ terraform plan --target=aws_instance.db-terra
$ terraform apply --target=aws_instance.db-terra
[ ... ]
  source_dest_check:                         "" => "true"                                                                                                    
  subnet_id:                                 "" => "subnet-09ccf71f6b4f69301"                  
  tags.%:                                    "" => "3"                                                                                                       
  tags.Name:                                 "" => "db0-terra"                                                                                               
  tags.role:                                 "" => "database"                                                                                                
  tags.scope:                                "" => "training"                                                                                                
  tenancy:                                   "" => "<computed>"                                                                                              
  volume_tags.%:                             "" => "<computed>"                                                                                              
  vpc_security_group_ids.#:                  "" => "<computed>"                                                                                              
aws_instance.db-terra: Still creating... (10s elapsed)                                                                                                       
aws_instance.db-terra: Still creating... (20s elapsed)                                                                                                       
aws_instance.db-terra: Still creating... (30s elapsed)                                                                                                       
aws_instance.db-terra: Provisioning with 'remote-exec'...                                                                                                    
aws_instance.db-terra (remote-exec): Connecting to remote host via SSH...                                                                                    
aws_instance.db-terra (remote-exec):   Host: 54.188.229.7                                                                                                    
aws_instance.db-terra (remote-exec):   User: ubuntu                                       
aws_instance.db-terra (remote-exec):   Password: false                                                                                                       
aws_instance.db-terra (remote-exec):   Private key: true                                                                                                     
aws_instance.db-terra (remote-exec):   SSH Agent: true                                                                                                       
aws_instance.db-terra (remote-exec):   Checking Host Key: false 
[ ... ]
aws_instance.db-terra (remote-exec): Processing triggers for man-db (2.7.5-1) ...
aws_instance.db-terra (remote-exec): Setting up libpython2.7-stdlib:amd64 (2.7.12-1ubuntu0~16.04.4) ...                                                      
aws_instance.db-terra (remote-exec): Setting up python2.7 (2.7.12-1ubuntu0~16.04.4) ...                                                                      
aws_instance.db-terra (remote-exec): Setting up libpython-stdlib:amd64 (2.7.12-1~16.04) ...                                                                  
aws_instance.db-terra (remote-exec): Setting up python (2.7.12-1~16.04) ...                                         
aws_instance.db-terra: Still creating... (1m0s elapsed)                                                             
aws_instance.db-terra: Provisioning with 'local-exec'...                                                                                                     
aws_instance.db-terra (local-exec): Executing: ["/bin/sh" "-c" "ansible-playbook -u ubuntu --ssh-common-args='-o StrictHostKeyChecking=no' -i '54.188.229.7,' --private-key ssh-keys/ansible-user -T 300 bd.yml"]                                                                                                          
                                                        
aws_instance.db-terra (local-exec): PLAY [all] *********************************************************************   
[ ... ] 
aws_instance.db-terra (local-exec): TASK [geerlingguy.mysql : Copy .my.cnf file with root password credentials.] ***
aws_instance.db-terra (local-exec): changed: [54.188.229.7]
                                                                                                                                                             
aws_instance.db-terra (local-exec): TASK [geerlingguy.mysql : Get list of hosts for the anonymous user.] ***********
aws_instance.db-terra: Still creating... (3m10s elapsed)
aws_instance.db-terra (local-exec): ok: [54.188.229.7]   
[ ... ] 
aws_instance.db-terra (local-exec): PLAY RECAP *********************************************************************                                         
aws_instance.db-terra (local-exec): 54.188.229.7               : ok=42   changed=15   unreachable=0    failed=0                                              

aws_instance.db-terra: Creation complete after 3m33s (ID: i-0ab70cd7c7d33203e)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

```

TODO : Add tag_terraform

Vous pouvez avoir le fichier [02-use-case.tf](https://github.com/x3rus/training/blob/d8d6613fb5f474913d4eb936fe77dd65dc90001b/terraform/terraManifest/02-use-case/02-use-case.tf).

L'ensemble du repository est disponible aussi : [repo de formation a ce point](https://github.com/x3rus/training/tree/d8d6613fb5f474913d4eb936fe77dd65dc90001b/terraform)

#### Populer la base de données 

Nous avons l'instance EC2 , configurée avec Mysql , nos utilisateurs , le mot de passe ... mais il manque quelque chose !! Les donnés dans la base de données. Pour ce faire, j'ai créé un **rôle** ansible nommé : **mysql-setup-data-example** , je n'aurais assurément pas le prix de l'originalité :P. 

Prenons 2 minutes pour le consulter, ce n'est pas vraiment requis , mais au moins vous aurez la solution complète.

Regardons les fichiers :

```
$ cd terraManifest/02-use-case/roles/mysql-setup-data-example
$ ls -R
.:
defaults  files  handlers  meta  README.md  tasks  templates  tests  vars

./defaults:

./files:
contacts.sql.gz  loadpi.sql

./handlers:

./meta:

./tasks:
main.yml

./templates:

./tests:

./vars:

```

Donc beaucoup de répertoires, pas beaucoup de fichiers :P , en fait je pense même que GIT va les enlevés, car c'est des répertoires vides, peut importe ceci est-ce que j'ai sur ma machine.

Sous le répertoire **files** nous avons les 2 fichiers dump avec le contenu de la base de donnés.
Sous le répertoire **task** , nous avons les instructions à réaliser .

Il n'y a pas beaucoup de ligne je les mets :P 

[main.yml](TODO)

```
 # Copy database dump file to remote host and restore it to database 'my_db'
- name: Copy database dump file pi
  copy:
    src: loadpi.sql
    dest: /tmp

- name: Import pi_dump.sql 
  mysql_db:
    state: import
    name: showpi
    target: /tmp/loadpi.sql

- name: Copy database dump file contact
  copy:
    src: contacts.sql.gz
    dest: /tmp

- name: Import contact_dump.sql 
  mysql_db:
    state: import
    name: contact
    target: /tmp/contacts.sql.gz

- name: Ansible delete file 
  find:
    paths: /tmp/
    patterns: "*.sql.*"
  register: files_to_delete

- name: Ansible remove sql files
  file:
    path: "{{ item.path }}"
    state: absent
  loop : "{{ files_to_delete.files }}"
```

Nous avons la copie du fichier SQL non compressé pour la base de données *PI*, ainsi que le chargement.
La deuxième partie est similaire cependant avec un fichier compressé pour la base de données de *contact*.

Par la suite, je fais une recherche des fichiers présents dans le répertoire /tmp avec le pattern sql , avec cette liste je fais le ménage en supprimant les fichiers. 

Ce n’est pas plus compliqué que ça , OK on va être réaliste, je ne suis pas encore un expert ansible, ça m'a pris un peu de temps, surtout la partie de cleanup , mais faut pas se décourager :D.

Maintenant l'intégration , dans l'ensemble de la chaine , mettons-le après la création de la base de données : bd.yml

```
 ---
- hosts: all
  become: yes
  become_user: root
  vars_files:
    - vars/mysql.yml
  roles:
    - { role: geerlingguy.mysql }
    - { role: mysql-setup-data-example }
```

TODO : Tag_terraform

Et voilà en plus de la configuration nous aurons des données dans la base de données.

L'ensemble du repository est disponible aussi : [repo de formation à ce point](https://github.com/x3rus/training/tree/9a52d1698abdf9a07e8f5f83cb1c06ffc055e87b/terraform)


## Provisionnement du serveur web

Nous avons la base de données, configurer , nous allons pouvoir passer au serveur web. Pour rappel le serveur web aura , 2 sites web :

* contacts.x3rus.com
* showpi.x3rus.com

Ce sont des sites web écrits en php , c'était le plus simple et rapide. Chacun des sites web établit une connexion mysql avec un nom d'utilisateur et mot de passe vers 1 serveur de base de données. En d'autres mots, le site web contact établira une connexion au serveur de base de donnée db-terra.0 et le site web showpi établira sa connexion sur le serveur mysql db-terra.1 . 

### Explication du rôle ansible

Donc le nom du rôle , attention roulement de tambour pour l'originalité :P , **apache-php-example**. Regardons le contenue : 

```
$ cd terraManifest/02-use-case/roles/apache-php-example
$ ls -R
.:
defaults  files  handlers  meta  README.md  tasks  templates  tests  vars

./defaults:
main.yml

./files:
001-contact.conf  001-showpi.conf

./handlers:
main.yml

./meta:
main.yml

./tasks:
main.yml

./templates:
contact-index.php.j2  showpi-index.php.j2

./tests:
inventory  test.yml

./vars:
main.yml
```

J'ai utilisé un script pour la génération de ce module , il y a un peu plus de fichiers et certains de ces fichiers ne furent pas édités pour avoir la bonne information ... ho well :P .

Nous allons nous concentrer sur quelques fichiers :

* **./tasks/main.yml** : ceci contient les instructions ansible qui doivent être réalisées.
* **./files/001-contact.conf et ./files/001-showpi.conf** : Les fichiers de la configuration apache.
* **./templates/contact-index.php.j2 et ./templates/showpi-index.php.j2** : Les fichiers php du site web.

#### Tâche du rôle

Les opérations de configuration de l'instance via ansible est relativement simples , l'ensemble est défini dans le fichier [tasks/main.yml](./terraManifest/02-use-case/roles/apache-php-example/tasks/main.yml)

Nous avons l'installation de l'ensemble des packages (apache2,libapache2-mod-php,...) en utilisant apt-get.

```
- name: install apache
  apt:
    name : "{{ item }}"
    state: present
    update_cache: true
  loop:
    - apache2
    - libapache2-mod-php
    - php-mysql
    - php-mbstring

```

La création du répertoire où les fichiers des sites web seront installés :

```
- name : Web sites directory
  file: 
    path : "{{ item }}" 
    state : directory
    owner : root 
    group : root 
  loop : 
    - /var/www/showpi
    - /var/www/contacts
```

Copie des fichiers de sites web avec le module de tamplate , j'y reviens dans la section suivante :

```
- template:
    src: contact-index.php.j2
    dest: /var/www/contacts/index.php
    owner: root
    group: root
    mode: "u=rw,g=r,o=r"

- template:
    src: showpi-index.php.j2
    dest: /var/www/showpi/index.php
    owner: root
    group: root
    mode: "u=rw,g=r,o=r"
```

Mise en place du fichier de configuration pour apache et redémarrage du service 

```
- name : Web site configuration file for contact
  copy:
    src : 001-contact.conf 
    dest : /etc/apache2/sites-enabled/
    mode : 0664
  notify:
    - restart apache
```

L'ensemble est relativement clair , cependant la partie template demande plus d'explication, donc continuons avec ça.


#### Introduction des variables avec ansible

Vous pouvez déjà conster qu'il y des fichiers sous le répertoire **files** et **templates** , les fichiers sous **files** seront installés tels quels . Dans le cas des fichiers sous **templates** , ce sont des fichiers de type [Jinja2,](http://jinja.pocoo.org/docs/2.10/) donc ils seront interprétés et les  variables seront substituées afin de générer le fichier final.

Wow, mais pourquoi des variables me direz vous ?
Pour répondre à la question, regardons le fichier :

```
<?php
$servername = "{{ mysqlContHost }}" ;
$username = "{{ mysqlContUser }}" ;
$password = "{{ mysqlContPass }}" ;
$dbname = "{{ mysqlContDB }}" ;

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
//
$sql = "SELECT id, nom , prenom  FROM contacts";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // output data of each row
    while($row = $result->fetch_assoc()) {
        echo "id: " . $row["id"]. " - Name: " . $row["nom"]. " " . $row["prenom"]. "<br>";
    }
} else {
    echo "0 results";
}
$conn->close();
?> 
```

Le site doit être en mesure d'établir une connexion mysql au serveur de base de données , dont il a besoin :

* **\$servername = "{{ mysqlContHost }}" ;** : D'un nom de serveur ou la connexion doit être initialisé
* **\$username = "{{ mysqlContUser }}" ;** : D'un nom d'utilisateur pour la connexion
* **\$password = "{{ mysqlContPass }}" ;** : D'un mot de passe  associé à l'utilisateur
* **\$dbname = "{{ mysqlContDB }}" ;**  : Du nom de la base de donnée 

Nous pourrions définir facilement le nom de la base de données ainsi que les informations d'authentification , cependant ceci sera plus compliqué pour l'adresse IP du serveur de base de données, car ceci est des adresses IP dynamiques. 

Si vous vous dites, mais pourquoi  n'avons nous  pas fait la même chose pour la base de données ? Nous allons le faire, je voulais avoir une explication simple pour débuter, nous avions déjà l'intégration terraforme ET ansible, je me suis dit que ce serait plus fluide sans ajouter un nombre significatif de variables :P.

Si nous prenons le fichier du site web __showpi__ nous aurons d'autres variables :

```
$servername = "{{ mysqlPiHost }}" ;
$username = "{{ mysqlPiUser }}" ;
$password = "{{ mysqlPiPass }}" ;
$dbname = "{{ mysqlPiDB }}" ;
```

Donc au total 8 variables :

* Contact :
    * mysqlContHost
    * mysqlContUser
    * mysqlContPass
    * mysqlContDB
* ShowPi
    * mysqlPiHost
    * mysqlPiUser
    * mysqlPiPass
    * mysqlPiDB 

Afin de définir ces variables, nous allons voir 2 mécanismes :

* La définition de ces dernières dans une variable , simplifiant la gestion et l'évolution . Ceci permet d'avoir une traçabilité via votre contrôleur de révision (svn , git , ... )
* La définition sur la ligne de commande est très pratique pour la phase de validation ou pour les valeurs dont nous n'avons pas l'information au démarrage,  telle que l'adresse IP du serveur de base de données :D.

Voici l'argument que nous allons utiliser lors de notre premier test , via la ligne de commande : 

```
--extra-="mysqlContHost=172.31.50.2 mysqlContUser=contact_user mysqlContPass=le_mot_pass mysqlContDB=contact  mysqlPiHost=172.30.50.4 mysqlPiUser=pi_user mysqlPiPass=lautre_passe mysqlPiDB=showpi"
```

C'est beau l'exemple, mais on veut le voir concrètement, donc continuons avec la configuration.

### Configuration du playbook 

Donc nous avons le rôle, des fichiers avec des variables ... nous allons lier l'ensemble.

Nous allons créer le fichier : [site.yml](./terraManifest/02-use-case/site.yml)

```
 ---
- hosts: all
  become: yes
  become_user: root
  roles:
    - apache-php-example
```

Grossomodo, on retrouve exactement les mêmes choses que pour la base de données , le nom du rôle est différent .

#### Modification du manifest terraform remote-exec

Bien entendu, nous devrons appliquer la même recette pour que pour les instances de serveurs de base de données, si nous désirons être en mesure d'utiliser **ansible**. Vous vous rappeler quand nous avions voulu utiliser **ansible** python n'était pas présent , nous allons donc mettre la même instruction **remote-exec** afin d'avoir python de présent.

```
    provisioner "remote-exec" {
        # Install Python for Ansible
         inline = ["sudo apt-get update && sudo apt-get -y install python "]

        connection {
            type        = "ssh"
            user        = "ubuntu"
            private_key = "${file("ssh-keys/ansible-user")}"
        }
    }

```

Version du fichier avec la modification : [02-use-case.tf](https://github.com/x3rus/training/blob/2480e1241e546ca5f3545caf520caa18019a1a29/terraform/terraManifest/02-use-case/02-use-case.tf).

#### Test d'utilisation d’Ansible 

La phase de validation sera de démarrer une instance EC2 et d'exécuter notre rôle ansible dessus .
Ceci va nous permettre de corriger la définition de notre rôle ansible s'il y a le moindre problème , sans avoir l'ensemble du temps requis pour démarrer et détruire l'instance EC2 ! 

```
$ terraform apply --target=aws_instance.web-terra
[...]
  vpc_security_group_ids.#:                  "" => "<computed>"              
aws_instance.web-terra: Still creating... (10s elapsed)                                                                
aws_instance.web-terra: Still creating... (20s elapsed)                                                                                                      
aws_instance.web-terra: Still creating... (30s elapsed)                                   
aws_instance.web-terra: Provisioning with 'remote-exec'...                                                               
aws_instance.web-terra (remote-exec): Connecting to remote host via SSH...                                                    
aws_instance.web-terra (remote-exec):   Host: 34.211.213.77                                                                                                  
aws_instance.web-terra (remote-exec):   User: ubuntu                                                                         
aws_instance.web-terra (remote-exec):   Password: false
[...]
aws_instance.web-terra: Creation complete after 1m14s (ID: i-0a191e4525e7736d5)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

$ ansible-playbook -u ubuntu --ssh-common-args='-o StrictHostKeyChecking=no' -i '34.211.213.77,' --private-key ssh-keys/ansible-user -T 300  --extra-="mysqlContHost=172.31.50.2 mysqlContUser=contact_user mysqlContPass=le_mot_pass mysqlContDB=contact  mysqlPiHost=172.30.50.4 mysqlPiUser=pi_user mysqlPiPass=lautre_passe mysqlPiDB=showpi" site.yml
$ ansible-playbook -u ubuntu --ssh-common-args='-o StrictHostKeyChecking=no' -i '34.211.213.77,' --private-key ssh-keys/ansible-user -T 300  --extra-="mysqlContHost=172.31.50.2 mysqlContUser=contact_user mysqlContPass=le_mot_pass mysqlContDB=contact  mysqlPiHost=172.30.50.4 mysqlPiUser=pi_user mysqlPiPass=lautre_passe mysqlPiDB=showpi" site.yml

PLAY [all] ***************************************************************

TASK [Gathering Facts] ***************************************
ok: [34.211.213.77]

TASK [apache-php-example : install apache]
[...]
PLAY RECAP **************************************************
34.211.213.77              : ok=8    changed=7    unreachable=0    failed=0  

```

Donc nous avons appliqué notre configuration ansible avec succès, nous allons pouvoir établir une connexion ssh et valider les fichiers de configurations 

```
$ ssh -l ubuntu -i ssh-keys/ansible-user 34.211.213.77

 # configuration du site contact 
ubuntu@ip-172-31-60-30:~$ head -30  /var/www/contacts/index.php 
<?php
$servername = "172.31.50.2" ;
$username = "contact_user" ;
$password = "le_mot_pass" ;
$dbname = "contact" ;

 # configuration du site showpi
ubuntu@ip-172-31-60-30:~$ head -30  /var/www/showpi/index.php 
<?php
$servername = "172.30.50.4" ;
$username = "pi_user" ;
$password = "lautre_passe" ;
$dbname = "showpi" ;

 # même chose pour la configuration apache

ubuntu@ip-172-31-60-30:~$ cat /etc/apache2/sites-enabled/001-contact.conf  | grep -v '#'
<VirtualHost *:80>
        ServerName contacts.x3rus.com

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/contacts/


        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>

```


## L'ensemble des pièces sont la il faut collé le tout

Comme le titre l'indique, nous avons tous les morceaux de disponible petit récapitulatif :

1. Terraform : Création de l'ensemble du réseaux, firewall , et instance EC2 .
2. Terraform : Configuration l'instance EC2 afin d'être en mesure d'utiliser Ansible.
3. Ansible (BD) : Nous pouvons utiliser ansible pour faire la configuration de la base de données , avec une commande l'ensemble est configuré.
    * un fichier est utilisé pour l'ensemble des variables de configuration : **vars/mysql.yml** a
        * Nom base de données
        * Nom utilisateur 
        * Password
4. Ansible (Apache) : Nous avons aussi l'ensemble de la configuration, mais nous devons passer en argument l'ensemble des informations :  
        * Nom base de données
        * Nom utilisateur 
        * Password

Notre défi ici est d'être en mesure de regrouper l'ensemble pour n'avoir qu'une commande, qui faire tout. Nous allons donc travailler sur la question des variables maintenant .

ICI Orthographe
