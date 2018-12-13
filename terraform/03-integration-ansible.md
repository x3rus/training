# Description integration ansible

Nous avons l'ensemble de nos ressources dans AWS , cependant soyons honnête pour le moment ça sert à rien , car les instances EC2 ne sont pas configurer.

![](./imgs/architecture-overview-Network-overview-web-and-bd-ec2.png)

Nous devons donc maintenant faire la configuration des machines :

* web-terra
* bd-terra-0
* bd-terra-1

Bien entendu nous venons de réaliser l'ensemble de la création dans AWS de manière automatique , nous n'allons pas poursuivre avec la création manuel des configuration. Nous allons donc voir la combinaison Terraform avec Ansible. 
Ceci n'est pas une formation Ansible donc je ne vais pas prendre le temps de voir l'ensemble des configurations ansible, mais mettre l'accent sur l'integration avec Terraform. J'essayerai un jour de faire une formation ansible... 

# Integration Ansible avec Terraform

Lors de l'utilisation de AWS avec terraform nous avons utilisé un [provider](https://www.terraform.io/docs/providers/index.html) ceci nous permet de faire la gestion des ressources , de l'infrastructure. Dans notre cas nous avons utilisé le [provider aws](https://www.terraform.io/docs/providers/aws/index.html) . 
Terraform offre un autre type [Provisioners](https://www.terraform.io/docs/provisioners/index.html) ceci permet de provisionner , de réaliser des opérations avant ou après la création des ressources.

Dans notre cas comme nous utilisons AWS , nous aurions pu faire la création d'un AMI personnalisé avec nos logiciels déjà présent, cependant nous devrions maintenant cette image dans l'ensemble des régions , l'évolution de cette dernière est pénible si nous désirons l'avoir à l'identique partout, des changements sur les instances créé dans le passons deviennent difficile à moins de détruire et recommencer. Ce que j'aime aussi de la solution avec ansible est que je suis agnostique au choix du cloud ou même si je choisie une installation sur site.

Terraform ne supporte pas aujourd'huis nativement Ansible, mais il existe un système de [provisioners](https://www.terraform.io/docs/provisioners/index.html) qui permet d'exécuter des commandes :

* [chef](https://www.terraform.io/docs/provisioners/chef.html) : Permet de configurer l'instance à l'aide du système chef.
* [Salt-masterless](https://www.terraform.io/docs/provisioners/salt-masterless.html) : Permet de faire du provisionning à l'aide de salt, yep il manque vraiment ansible ;).
* [Connection](https://www.terraform.io/docs/provisioners/connection.html) : Permet de faire la copie d'un fichier via ssh ou winRm ( Remote pas remove :P ) 
* [File](https://www.terraform.io/docs/provisioners/file.html) : Permet de faire la copie d'un fichier d'une ressource créer , la différence ici avec le précédent et que cette méthode ne permet pas de faire la copie vers une instance autre que celle créer alors que Connection permet de définir un hostname.
* [habitat](https://www.terraform.io/docs/provisioners/habitat.html) : Permet d'executer l'application [habitat](https://www.habitat.sh/) créée par Chef, ceci permet de définir des services à démarrer. Je ne connais pas .
* [local-exec](https://www.terraform.io/docs/provisioners/local-exec.html) : Permet d'executer des instructions sur le serveur qui initie les instructions terraform. 
* [null_ressource](https://www.terraform.io/docs/provisioners/null_resource.html) : Ce système permet lorsque vous initialisez plusieurs instance avec l'option **count**, de regrouper les informations telle que l'ip priver , regardez l'exemple sur le site. Je vais peut-être faire un exemple mais rien n'est sûr à l'écriture des ces lignes. 
* [remote-exec](https://www.terraform.io/docs/provisioners/remote-exec.html) : Permet d'exécuter une instruction sur l'instance initializé, support aussi bien ssh que winrm .

Dans ma logique je vais donc faire le déploiement d'un rôle ansible pour la configuration apache. En utilisant l'instruction [local-exec](https://www.terraform.io/docs/provisioners/local-exec.html) , donc le processus utilisera l'application ansible , préalablement installé sur mon poste et le playbook aussi présent localement. 


Nous allons débuter par la configuration des bases de données , car elles sont requisent pour le serveur web.


## Revue général de notre objectif

j'aime faire un rappel rapide de l'objectif, car il y a un grand nombre de personne qui n'ont pas lu l'ensemble du document , moi le premier je survole jusqu'a la section que je recherche :P.

Donc voici ce que nous allons faire :

![](./imgs/apps-overview-lst-configurations.png)

Nous avons 1 serveur web qui aura apache d'installé et répondra à 2 nom de domaine :

* contacts.x3rus.com
* pi.x3rus.com

Les sites web iront chercher le contenu dans une base de donnée :

* contact : pour le site web contacts.x3rus.com
* showpi : pour le site web pi.x3rus.com 

Les 2 serveurs de base de données sont configuré à l'identique afin de simplifier le processus de déploiement. Ils auront la base de donnée mysql d'installé et la configuration des 2 base de données incluant l'import des données.


## Intro ansible "rapide" 

Bon je suis devant la machine et je me questionne, est-ce que je fais une intro ansible , oui / non ... j'avoue que je suis en questionnement. Je vais donc en faire une super rapide , afin que mes propos puissent être compris par tous !!

Information sur [ansible depuis wikipedia](https://fr.wikipedia.org/wiki/Ansible_\(logiciel\))

> Ansible est une plate-forme logicielle libre pour la configuration et la gestion des ordinateurs. Elle combine le déploiement de logiciels multi-nœuds, l'exécution des tâches ad-hoc, et la gestion de configuration. Elle gère les différents nœuds par-dessus SSH et ne nécessite l'installation d'aucun logiciel supplémentaire à distance sur eux. Les modules fonctionnent grâce à JSON et à la sortie standard et peuvent être écrits dans n'importe quel langage de programmation. Le système utilise YAML pour exprimer des descriptions réutilisables de systèmes.
> 
> Ansible Inc. était la société derrière le développement commercial de l'application Ansible. Red Hat rachète Ansible Inc. en octobre 2015.
> 
> Le nom Ansible a été choisi en référence au terme Ansible choisi par Ursula Le Guin dans ses romans de science-fiction pour désigner un moyen de communication plus rapide que la lumière.

Ansible pousse donc les instructions via SSH .

### Ansible, les modules disponible

Ansible vient avec une boite à outils complète composé d'un grand nombre de module : [module par catégorie](http://docs.ansible.com/ansible/latest/modules/modules_by_category.html).

Comme vous pouvez le voir il y a un grand nombre de module disponible pour plusieurs type d'activités :

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

Un [playbook](https://docs.ansible.com/ansible/2.4/ansible-playbook.html) dans ansible permet de définir une liste d'instruction qui seront réalisé sur un serveur. 
Donc pour faire le provisionnement de nos serveurs , je vais faire 2 playbook :

1. serveur web : site.yml
2. serveur de BD: db.yml

Les playbooks utiliserons une liste de rôle qui eux même utiliserons les modules pour réaliser les opérations. 

### Installation de ansible

Afin d'être en mesure de combiner Terreform et Ansible , tous comme vous avez du installé terraform il vous faudra Ansible :P. 

Je vous laisse le lien vers le documentation officiel : [https://docs.ansible.com/ansible/2.5/installation_guide/intro_installation.html](https://docs.ansible.com/ansible/2.5/installation_guide/intro_installation.html)

## Provisionnement des serveurs de base de données

Bon pour ceux qui me connaisse, vous savez que j'ai de la difficulté à être concis, on va dire que je vais être fidèle à moi même encore une fois :P. On va prendre le temps de décortiquer le processus de provisionnement du serveur de Base de donnée incluant la partie Ansible. 

### Explication du playbook ansible
