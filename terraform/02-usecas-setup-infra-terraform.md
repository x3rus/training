# Description

J'ai cherché quelle cas d'utilisation j'allais faire et comme nous allons utiliser AWS et que j'avais fait une présentation de AWS dans le passé j'ai pensé reprendre mon cas d'utilisation que j'avais fait manuellement. Ceci vous permettra aussi d'avoir la possibilité de voir la même opération en mode manuel. 
Ceci n'est PAS un requis mais un plus tout simplement , voici les liens :

* Texte :
    * 
* Vidéos (Playlist) :

Je vais donc commencé par présenté le cas d'utilisation qui est presque pareille que la dernière fois mais avec un petit changement il n'y aura pas de docker dans la solution présenté ici. J'avais utilisé docker la dernière fois pour simplifier mon déploiement applicatif , cependant dans le cas d'utilisation ici comme je veux utiliser __Ansible__ je désire avoir plus de complexité que simplement transmettre un conteneur.

## Présentation du cas d'utilisation

Voici donc le cas d'utilisation qui sera mis en place , Nous allons mettre un serveur GNU/Linux avec apache qui sera configurer pour 2 site web (virtual host) :

* contacts.x3rus.com
* showpi.x3rus.com

Ces 2 sites web utilise des bases de données pour stocker leurs données. Nous allons donc créer 2 serveur GNU/Linux avec Mysql :

* 1 pour le site contacts.x3rus.com
* 1 pour le site showpi.x3rus.com

Donc nous aurons 3 instances EC2 GNU/Linux ! 

Bien entendu, ces instances EC2 ont besoin d'une infrastructure autour , telle que les clé ssh pour être en mesure d'établir une connexion ; un réseau spécifique pour être en mesure d'isolé cette environnement des autres services et de rêgle de firewall afin de permettre la communication entre les services ainsi que l'exposition de services.

Voici une représentation graphique de l'ensemble des pièces du puzzle qui seront mise en place  :

![](./imgs/architecture-overview-chaque-piece.png) 

De plus voici une représentation du flux réseau :

![](./imgs/architecture-overview-network-flow.png)

Je vais prendre le temps de les expliquer lors de leur création , cependant je voulais mettre en évidence que nous allons faire la création de plusieurs élément dans AWS. Nous ne couvrirons pas pour cette partie la mise en place du Elastic Load Balancer ou l'auto scaling automatique . Peut-être plus tard l'avenir est pleine de surprise :P.

Dans la démonstration , je n'utilise QUE les images GNU/Linux vanille de Amazon , je ne fait pas une configuration spécifique pour mes services , l'ensemble de la configuration des instances EC2 seront réalisé avec Ansible. Je suis désolé, je n'ai pas encore pris le temps de faire une formation sur Ansible, je suis encore en période d'exploration :P , cependant nous dirons que ceci servira d'introduction :P . 

# Réalisation de la configuration 

Je vais utiliser la même séquence que lors de mon apprentissage personnel, voici donc les étapes haut niveau que nous allons couvrir : 

1. Configuration de l'environnement 
    1. Installation de terraform
    2. Création d'un utilisateur dans AWS pour terraform
    3. Test de communication 
2. Réalisation du cas d'exemple
    1. Création des clés OpenSSH et déploiement dans AWS
    2. Création du réseau
        1. Identification du VPC par défault
        2. Création de 2 subnet 
            * serveur web 
            * serveur de base de données
        3. Configuration des règles de firewall (security groups)
    3. Création des instances EC2
        1. Configuration de ces dernières avec Ansible
        2. Partage de variables entre Terraform et Ansible

Je couvrirai aussi à la fin, si le temps me le permet dans la vidéo, mais au moins par écrit de problème que j'ai rencontré.

Prendre note que l'ensemble sera dans le répertoire : **terraform/terraManifest**

OK LET'S GO !!

TODO : add picture here 

## Configuration de l'environnement

Pour ce faire j'ai simplement utilisé la page [Get Started de terraform](https://www.terraform.io/intro/getting-started/install.html) . 
Rapidement je vais le couvrir, cependant s'il y a un problème vous référer à la page de terraform :

### Installation de Terraform 

Vous pouvez le télécharger pour votre plateforme  : https://www.terraform.io/downloads.html
Pour Ubuntu :

```
$ sudo apt-get install unzip
$ wget https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip
$ unzip terraform_0.11.10_linux_amd64.zip
$ sudo mv terraform /usr/local/bin/
$ terraform --version 
```

Pour Arch Linux ( allez un peu de pub pour cette distro aussi :P , même si ça change RIEN. T'es pas meilleur sur arch que sur Ubuntu ou une autre distro !!)

```
$ aurman terraform
```

Dans les 2 cas, on va pas me dire que c'est compliqué !!

### Création d'un utilisateur dans AWS

Vous avez 2 Options , mais choisissez pas la première :P , c'est pas propre . Bon explication sans farce :

* **Option 1** : Utilisation de la clé __ROOT__ super admin du compte ,  la problématique avec cette méthode est qu'il n'y a pas de possibilité de limité les permissions. De plus ceci offre l'accès à l'ensemble du compte. Vous n'aurez qu'une clé , alors que lors de l'utilisation en entreprise de terraform vous désirez offrir un compte par équipe ou utilisateur.
* **Option 2** : Création d'un utilisateur associé qui sera utilisé par **Terraform** , ceci vous offre la possibilité de limité les permissions au ressources. De plus vous pouvez révoquez l'accès sans impacter les autres équipes qui utilise AWS avec terraform , car ceci est une clé unique par utilisateur. 

Nous allons prendre l'option 2 , car elle est plus propre , pour se faire allé sur le [gestionnaire d'utilisateur IAM](https://console.aws.amazon.com/iam/home?region=us-west-2#/users). 

Voici le résultat pour moi j'ai déjà 1 utilisateur :

![](./imgs/04-iam-user-view.png)

Je clique donc sur le bouton **Add user** en haut. Je définie le nom de l'utilisateur et le type d'utilisateur , dans notre cas ce ne sera pas un utilisateur interactif, mais un utilisateur qui utilise l'API de AWS.

![](./imgs/05-create-iam-user-api.png) 

Pour les besoins de la présentation je vais définir l'utilisateur comme administrateur afin de me simplifier la vie en terme de permission. Nous allons explorer les possibilités de **terraform** , nous voulons donc gérer les problèmes de ce système pas avoir en plus des problèmes de permission. Bien entendu une fois la recette trouvé je vous invite à explorer aussi le système IAM de AWS. 
Honnêtement je pense que j'ai créer ce groupe , si c'est le cas j'ajoute aussi une copie d'écran des permission du groupe. 

![](./imgs/05-create-iam-user-set-group.png)

![](./imgs/05-create-iam-user-view-group-admin.png)

Vous pouvez valider le résultat :

![](./imgs/05-create-iam-user-review.png)

Et Voilà le résultat :

![](./imgs/05-create-iam-user-resultat.png)

Vous pouvez téléchargé le csv , très pratique quand vous créez plusieurs utilisateur . **ATTENTION** : la clé secret ne sera plus jamais disponible vous devez absolument en faire une copie maintenant !!

Résultat vous avez les identifiants requis pour Terraform :

* Access key ID :  ABIASDLASDIHV6QNZASQ
* Secret access key : 06mcwWI7MhP59cKss5PQjPyPGzvF7k/gNCdZGKYc

__Note__ : N'utilisez pas la clé ci-dessus elle n'est pas bonne :P , vous aurez des problèmes d'accès j'ai changé les valeurs pour pas que l'on puisse l'utiliser.

### Test de communication 

Nous allons créer un répertoire pour chacun de nos test :

```
$ mkdir -p  terraManifest/01-validation
```

Voici la première version de notre configuration **terraform**  : terraManifest/01-validation/01-test-terraform.tf

```
 ########
 # Vars #

variable "aws_region" { default = "us-west-2" } # US-oregon

 # AWS SDK auth
provider "aws" {
    region = "${var.aws_region}"
  	access_key = "ABIASDLASDIHV6QNZASQ"
	secret_key = "06mcwWI7MhP59cKss5PQjPyPGzvF7k/gNCdZGKYc"
}

 # Extract last AWS ubuntu AMazon Image (AMI)
 # Ref :https://www.andreagrandi.it/2017/08/25/getting-latest-ubuntu-ami-with-terraform/
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

}
```

Fichier d'origin : [01-test-terraform.tf](https://github.com/x3rus/training/blob/a0e33ab3753426d010972f57ea2f02119fa916e8/terraform/terraManifest/01-validation/01-test-terraform.tf)

Détaillons un peu le contenu de cette configuration **terraform** 

* Création d'une variable qui contiendra le nom de la région que nous désirons manipuler , dans mon cas j'utilise la région de l'oregon. Je pourrais utiliser celui du canada , mais le prix est moins chère au États-Unis :P. Comme ceci est pour la formation je réduit mes coûts au maximum . Vous avez la liste des régions et le code associé disponible sur la documentation de aws : [Région et zone disponible](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html).
    * Le nom de la variables est **aws\_region**

    ```
        variable "aws_region" { default = "us-west-2" } # US-oregon
    ```

* Nous définissons le type de **provider** à utiliser , pour les curieux la documentation du provider aws est disponible sur le site de **terraform** : [provider aws](https://www.terraform.io/docs/providers/aws/index.html) . Nous indiquons où nous désirons établir notre connexion , dans notre cas nous reprenons la variable de la région préalablement définie. Nous indiquons aussi les critères d'authentification pour avoir accès l'équivalent de user / password , pour aws ceci est l'__access key__ et __secret key__

    ```
    provider "aws" {
        region = "${var.aws_region}"
      	access_key = "ABIASDLASDIHV6QNZASQ"
	    secret_key = "06mcwWI7MhP59cKss5PQjPyPGzvF7k/gNCdZGKYc"
    }
    ```

* Dernier bloque , nous allons faire une recherche pour extraire l'information depuis AWS pour la version la plus récente de l'image AMI disponible pour Ubuntu 16.04 ( __aka xenial__ ) de type __hvm__ disponible dans la région où nous nous sommes connecté. Nous utiliserons cette entré par la suite lors de la création d'une instance EC2 j'y reviendrai.

    ```
    data "aws_ami" "ubuntu" {
        most_recent = true

        filter {
            name   = "name"
            values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
        }

        filter {
            name   = "virtualization-type"
            values = ["hvm"]
        }

    }
    ```

    * En d'autre mot cette commande est l'équivalant d'aller sur la page [Liste des AMI pour l'oregon](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;name=ubuntu;search=16.04;sort=name) , faire la recherche pour ubuntu 16.04 dans les AMI public et extraire la plus récente .

    ![](./imgs/06-search-ami-last-ubuntu.png)

Pour rappel ici nous ne validons que la connectivité, nous réaliserons de grande chose par la suite :P .

Afin d'être en mesure d'utiliser **terraform** , vous allez avoir besoin d'initialiser votre espace de travail. L'initialisation va télécharger les plugins requis, ce dernier va lire le fichier de configuration et voir les __providers__ définie. Il téléchargera les binaires en conséquence. Lors de l'opération voici ce que vous devriez avoir : 

```
 $ terraform init                 
 
Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "aws" (1.43.2)...                                                                                                          
                         
The following providers do not have any version constraints in configuration,
so the latest version was installed.
            
To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the         
corresponding provider blocks in configuration, with the constraint strings
suggested below.
            
* provider.aws: version = "~> 1.43"   
                        
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.
                                                                              
If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```

Si vous regardez dans votre répertoire de travail , vous constaterez que la commande a généré un répertoire __.terraform__ contenant un répertoire plugins , avec un fichier binaire. Assez volumineux soit dit en passant 90 Megs.

```
$ ls -ltr .terraform/plugins/linux_amd64/
total 92772
-rwxr-xr-x 1 xerus xerus 94989024 Nov 14 08:21 terraform-provider-aws_v1.43.2_x4
-rwxr-xr-x 1 xerus xerus       79 Nov 14 08:21 lock.json

```

Un des gros points positif avec Terraform est qu'il est possible d'avoir l'information de ce qui sera réalisé avant de poser une action. Avec l'option **plan**, ceci est important afin d'être en mesure de prédire l'action et de la valider en amont au lieu de la corriger par la suite :P.

```
$ terraform plan                                                                                                                
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.
                                          
data.aws_ami.ubuntu: Refreshing state... 
 ------------------------------------------------------------------------                                                                                      
No changes. Infrastructure is up-to-date. 
This means that Terraform did not detect any differences between your 
configuration and real physical resources that exist. As a result, no  
actions need to be performed.
```

Comme nous pouvons le voir ci-dessus le message : **No changes. Infrastructure is up-to-date.** , ce qui était prévisible, car nous n'avons pas réaliser d'actions de création ou destructions.

Si vous avez le message suivant : 

```
$ terraform plan 
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


Error: Error refreshing state: 1 error(s) occurred:

* provider.aws: error validating provider credentials: error calling sts:GetCallerIdentity: InvalidClientTokenId: The security token included in the request is invalid.
        status code: 403, request id: c4f63d75-e811-11e8-9152-dbfe67261934
```

Raisons :

1. Vous avez copier collé le fichier de configuration sans changé l'access et secret key :P , malheureusement il faut mettre vos identifiants 
2. Les permissions attribué dans IAM , ne sont pas adéquat :-/ 


Je vous laisse malheureusement chercher , je vous conseille fortement de détruire et refaire l'utilisateur si requis !!

Maintenant il est temps de faire l'application de la configuration avec l'option **apply**, ci-dessous le résultat :

```
terraform apply 
data.aws_ami.ubuntu: Refreshing state...

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

Comme attendu , l'opération est complété et aucun ressources fut : ajouté , changé ou détruite.
Bien que rien ne fut changer dans l'environnement AWS, il y a eu un changement dans le répertoire de travail , un fichier a fait son apparition **terraform.tfstate**. Ce dernier sera réécrit à chaque utilisation j'ai donc fait une copie  :  [terraform.tfstate_run01](./terraManifest/01-validation/terraform.tfstate_run01)
Ce fichier conserve l'état de la configuration qui fut exécuté . Si vous ouvrez le fichier vous constaterez que le fichier contient l'ensemble de l'information de l'AMI , nous y retrouvons :

* "id": "ami-0afae182eed9d2b46",
* "architecture": "x86_64",
* "creation_date": "2018-11-07T16:54:57.000Z"
* "block_device_mappings.2547816212.ebs.volume_size": "8",

Je vous laisse regarder la suite ... cependant si je prend le id et que je le recherche dans la même page des AMI mentionné plus tôt , je retrouve l'information : 

![](./imgs/06-search-ami-last-ubuntu-with-id.png)

Ce fichier est donc le fichier de l'état !! Il sera rafraichie et bonifié au fur et à mesure de l'utilisation

## Réalisation du cas d'exemple

Bon nous allons débuter le cas d'exemple , je vais faire un répertoire pour ce cas d'utilisation et utiliser les commits afin de vous fournir les fichiers finaux à chaque étape. Pourquoi ce mode de fonctionnement , simplement parce que je veux capitalisé sur le fichier d'état des exécutions passé.

```
$ mkdir terraManifest/02-use-case
$ cd terraManifest/02-use-case
```

Pour rappel voici les étapes qui seront réalisées :

    1. Création des clés OpenSSH et déploiement dans AWS
    2. Création du réseau
        1. Identification du VPC par défault
        2. Création de 2 subnet 
            * serveur web 
            * serveur de base de données
        3. Configuration des règles de firewall (security groups)
    3. Création des instances EC2
        1. Configuration de ces dernières avec Ansible
        2. Partage de variables entre Terraform et Ansible


### Création des clés OpenSSH et déploiement dans AWS

Je débute avec les clés ssh , car ceci est simple , ne génère PAS de coût et nous serons en mesure de visualisé le succès de l'opération facilement.

Premièrement visualisons les clés actuellement disponible , à l'URL [Key pair](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:sort=keyName) ( encore une fois je suis sur la région de l'Oregon ) 

![](./imgs/07-aws-view-key-pair-initial.png)

Pour le moment aucune clé n'est présente ! 

Bien entendu la clé privé ssh ne se trouvant pas dans AWS , nous allons faire la création de la clé sur notre station et pousser la clé public . Débutons donc par la création des clés :

```bash
$ mkdir ssh-keys && cd ssh-keys
$ ssh-keygen -t rsa -b 2048 -f ./admin-user
$ ssh-keygen -t rsa -b 2048 -f ./ansible-user

$ ls 
admin-user  admin-user.pub  ansible-user  ansible-user.pub
```

Donc les clés des 2 utilisateurs admin et ansible , les clés privé sans extension et les clés publique avec l'extension .pub.

Nous allons reprendre sensiblement la configuration initiale :

```
 ########
 # Vars #

variable "aws_region" { default = "us-west-2" } # US-oregon

 # AWS SDK auth
provider "aws" {
    region = "${var.aws_region}"
    access_key = "ABIASDLASDIHV6QNZASQ"
    secret_key = "06mcwWI7MhP59cKss5PQjPyPGzvF7k/gNCdZGKYc"
}

```

Nous allons ajouter par la suite la section pour les clés : 

```
 ############
 # SSH keys #

resource "aws_key_pair" "admin" {
  key_name   = "admin-key"

  # contenu du fichier : ssh-keys/admin-user.pub
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDReMyXDOfuGipgcQViDTr3kqfbLVbIegJI+j3Br2wgX5CQXkWoFqKKZv3JIS4RnZdyQ3HCf8hbwUA1SoW4ngOAARToLYbMA80bHilZK5AzpYoTVH9GgfruLeq/ljJJAyh33vQgk26VX63mBIlp7cgxMx96T2iSqUuNbylXHgEOhPXMytv7FT4JcxMhNIRCq9YnsS8nD7+6GrJ7tSnochTauXs3OrM8bTA0AgZfj0PrC8aDZRCEShPU9QEjGTrtIX5AVcRoP01UInk1JWfQIBk1x5WPKYUDXQIrZPyLkWJ0Y6H7qcLKyBmDqTrEuMZ6fi9zcpEFkkg3wyC9ERr/UmVx xerus@goishi"
}


resource "aws_key_pair" "ansible" {
  key_name   = "ansible-key"

  # contenu du fichier : ssh-keys/ansible-user.pub
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDr1Av8Kj8LqsI6cK31n4IElsxsGemzDXAI8NSCSRtTlNh8dJIIXpWnrGFSM9NU8++4qQmlYv+5uRhKS1SMZcPgRlcNGIBGLQxolFVw437zvt5O5mgLePRjgXpQWF/0fwx4iKark9Djyt8eHjSbTHCqpflT2xgFPMq0sJFJWmIMcGMkIh436AbjubvlgB8K1CGJzbTM4xHhlEywrggDekUcvXD2IKQFHAbO1pU/47krLdaOEhY0KeHnxfrBLU4RLxn1lyQkWLqLvuM+7o4j5lcMS/v3CC5t8I80uMByK76TC7qFOmZdU0jdo0tJBDzCBw1EmjIkD9urO1ZfL+r7FSbH xerus@goishi"
}
```

Voici le lien vers la documentation avec l'ensemble des options possible pour cette ressource : [aws_key_pair](https://www.terraform.io/docs/providers/aws/r/key_pair.html)

Validons que ceci fonctionne, comme ceci est un nouveau répertoire je dois initialiser le répertoire afin d'avoir les modules requis , dans notre cas AWS.

```
$ terraform  init 
  Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "aws" (1.45.0)...
The following providers do not have any version constraints in configuration,
so the latest version was installed.
corresponding provider blocks in configuration, with the constraint strings
suggested below.                     
                                                     
* provider.aws: version = "~> 1.45"      
                                                                        
Terraform has been successfully initialized!
                                                                            
You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.
                                                                            
If you ever set or change modules or backend configuration for Terraform,   
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```


* Regardons ce qui devrais être exécuté :

```
$ terraform  plan                                                                                                           
Refreshing Terraform state in-memory prior to plan... 
The refreshed state will be used to calculate this plan, but will not be 
persisted to local or remote state storage. 
------------------------------------------------------------------------                                                                                      
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create 
 Terraform will perform the following actions:  
  + aws_key_pair.admin
      id:          <computed>
      fingerprint: <computed>
      key_name:    "admin-key"
      public_key:  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDReMyXDOfuGipgcQViDTr3kqfbLVbIegJI+j3Br2wgX5CQXkWoFqKKZv3JIS4RnZdyQ3HCf8hbwUA1SoW4ngOAARToLYbMA80bH$
lZK5AzpYoTVH9GgfruLeq/ljJJAyh33vQgk26VX63mBIlp7cgxMx96T2iSqUuNbylXHgEOhPXMytv7FT4JcxMhNIRCq9YnsS8nD7+6GrJ7tSnochTauXs3OrM8bTA0AgZfj0PrC8aDZRCEShPU9QEjGTrtIX5$VcRoP01UInk1JWfQIBk1x5WPKYUDXQIrZPyLkWJ0Y6H7qcLKyBmDqTrEuMZ6fi9zcpEFkkg3wyC9ERr/UmVx xerus@goishi"                                                                                                                                                                                                                         
  + aws_key_pair.ansible
      id:          <computed>
      fingerprint: <computed>             
      key_name:    "ansible-key"
      public_key:  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDr1Av8Kj8LqsI6cK31n4IElsxsGemzDXAI8NSCSRtTlNh8dJIIXpWnrGFSM9NU8++4qQmlYv+5uRhKS1SMZcPgRlcNGIBGLQxol$
Vw437zvt5O5mgLePRjgXpQWF/0fwx4iKark9Djyt8eHjSbTHCqpflT2xgFPMq0sJFJWmIMcGMkIh436AbjubvlgB8K1CGJzbTM4xHhlEywrggDekUcvXD2IKQFHAbO1pU/47krLdaOEhY0KeHnxfrBLU4RLxn$
lyQkWLqLvuM+7o4j5lcMS/v3CC5t8I80uMByK76TC7qFOmZdU0jdo0tJBDzCBw1EmjIkD9urO1ZfL+r7FSbH xerus@goishi"

                    
Plan: 2 to add, 0 to change, 0 to destroy.
                               
------------------------------------------------------------------------
                                
Note: You didn't specify an "-out" parameter to save this plan, so Terraform can't guarantee that exactly these actions will be performed if "terraform apply" is subsequently run. 
```

Comme vous pouvez le voir le système nous indique qu'il y a des changements qui seront appliqué , 2 Ajouts dans notre cas les 2 clés SSH. Si vous retournez à l'URL pour voir les clés rien ne fut encore réalisé.

Nous allons appliquer les configurations :

```
$ terraform  apply                                                                                                          
An execution plan has been generated and is shown below. 
Resource actions are indicated with the following symbols: 
  + create
Terraform will perform the following actions: 
  + aws_key_pair.admin                                                                                                                                        
      id:          <computed>
      fingerprint: <computed>
      key_name:    "admin-key"
      public_key:  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDReMyXDOfuGipgcQViDTr3kqfbLVbIegJI+j3Br2wgX5CQXkWoFqKKZv3JIS4RnZdyQ3HCf8hbwUA1SoW4ngOAARToLYbMA80bH$lZK5AzpYoTVH9GgfruLeq/ljJJAyh33vQgk26VX63mBIlp7cgxMx96T2iSqUuNbylXHgEOhPXMytv7FT4JcxMhNIRCq9YnsS8nD7+6GrJ7tSnochTauXs3OrM8bTA0AgZfj0PrC8aDZRCEShPU9QEjGTrtIX5$VcRoP01UInk1JWfQIBk1x5WPKYUDXQIrZPyLkWJ0Y6H7qcLKyBmDqTrEuMZ6fi9zcpEFkkg3wyC9ERr/UmVx xerus@goishi"                                                           

  + aws_key_pair.ansible
      id:          <computed>
      fingerprint: <computed>
      key_name:    "ansible-key"
      public_key:  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDr1Av8Kj8LqsI6cK31n4IElsxsGemzDXAI8NSCSRtTlNh8dJIIXpWnrGFSM9NU8++4qQmlYv+5uRhKS1SMZcPgRlcNGIBGLQxol$Vw437zvt5O5mgLePRjgXpQWF/0fwx4iKark9Djyt8eHjSbTHCqpflT2xgFPMq0sJFJWmIMcGMkIh436AbjubvlgB8K1CGJzbTM4xHhlEywrggDekUcvXD2IKQFHAbO1pU/47krLdaOEhY0KeHnxfrBLU4RLxn$lyQkWLqLvuM+7o4j5lcMS/v3CC5t8I80uMByK76TC7qFOmZdU0jdo0tJBDzCBw1EmjIkD9urO1ZfL+r7FSbH xerus@goishi"                                                           


Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

```

Je dois confirmer que je désire que la création soit réalisé !!!

```
aws_key_pair.admin: Creating...
  fingerprint: "" => "<computed>"
  key_name:    "" => "admin-key"
  public_key:  "" => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDReMyXDOfuGipgcQViDTr3kqfbLVbIegJI+j3Br2wgX5CQXkWoFqKKZv3JIS4RnZdyQ3HCf8hbwUA1SoW4ngOAARToLYbMA80bHilZK5AzpYoTVH9GgfruLeq/ljJJAyh33vQgk26VX63mBIlp7cgxMx96T2iSqUuNbylXHgEOhPXMytv7FT4JcxMhNIRCq9YnsS8nD7+6GrJ7tSnochTauXs3OrM8bTA0AgZfj0PrC8aDZRCEShPU9QEjGTrtIX5AVcRoP01UInk1JWfQIBk1x5WPKYUDXQIrZPyLkWJ0Y6H7qcLKyBmDqTrEuMZ6fi9zcpEFkkg3wyC9ERr/UmVx xerus@goishi"                                                         
aws_key_pair.ansible: Creating...
  fingerprint: "" => "<computed>"
  key_name:    "" => "ansible-key"
  public_key:  "" => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDr1Av8Kj8LqsI6cK31n4IElsxsGemzDXAI8NSCSRtTlNh8dJIIXpWnrGFSM9NU8++4qQmlYv+5uRhKS1SMZcPgRlcNGIBGLQxolFVw437zvt5O5mgLePRjgXpQWF/0fwx4iKark9Djyt8eHjSbTHCqpflT2xgFPMq0sJFJWmIMcGMkIh436AbjubvlgB8K1CGJzbTM4xHhlEywrggDekUcvXD2IKQFHAbO1pU/47krLdaOEhY0KeHnxfrBLU4RLxn1lyQkWLqLvuM+7o4j5lcMS/v3CC5t8I80uMByK76TC7qFOmZdU0jdo0tJBDzCBw1EmjIkD9urO1ZfL+r7FSbH xerus@goishi"                                                         
aws_key_pair.ansible: Creation complete after 1s (ID: ansible-key)
aws_key_pair.admin: Creation complete after 1s (ID: admin-key)

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

```

Nous avons maintenant les 2 clés créés :

![](./imgs/07-aws-view-key-pair-with-key.png)


Dans le cadre de l'ajout des clés, il n'y a pas de coûts relié cependant lorsque nous allons créer des instances EC2 , vous voudrez probablement détruire vos instances par la suite . Profitons de l'occasion pour couvrir tout de suite ce point . Avec l'option **destroy** vous pouvez détruire ce qui est contenu dans le manifeste de terraform.

```
 terraform destroy
aws_key_pair.admin: Refreshing state... (ID: admin-key)
aws_key_pair.ansible: Refreshing state... (ID: ansible-key)

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  - aws_key_pair.admin

  - aws_key_pair.ansible


Plan: 0 to add, 0 to change, 2 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_key_pair.ansible: Destroying... (ID: ansible-key)
aws_key_pair.admin: Destroying... (ID: admin-key)
aws_key_pair.ansible: Destruction complete after 1s
aws_key_pair.admin: Destruction complete after 1s

Destroy complete! Resources: 2 destroyed.
```

Encore une fois je dois confirmer l'opération . Si vous retournez à l'adresse : [aws key pair](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:sort=keyName) , l'ensemble des clés ont disparu :D , magie .


**VERSION FINAL FICHIER** : [02-use-case.tf](https://github.com/x3rus/training/blob/d5c66cb650a05f4d10e5ddd942ef00bcd43aa3c0/terraform/terraManifest/02-use-case/02-use-case.tf)

#### Visualisation fichier d'état 

Je vais reprendre quelques minutes pour le fichiers d'état , suite à l'exécution de l'ajout des clés nous avons eu le fichier : [states/terraform-creation-key.tfstate](./terraManifest/02-use-case/states/terraform-creation-key.tfstate) 

```
            "resources": {
                "aws_key_pair.admin": {
                    "type": "aws_key_pair",
                    "depends_on": [],
                    "primary": {
                        "id": "admin-key",
                        "attributes": {
                            "fingerprint": "41:df:80:06:33:34:b4:fd:cc:d5:79:8c:00:28:08:b4",
                            "id": "admin-key",
                            "key_name": "admin-key",
                            "public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDReMyXDOfuGipgcQViDTr3kqfbLVbIegJI+j3Br2wgX5CQXkWoFqKKZv3JIS4RnZdyQ3HCf8hbwUA1SoW4ngOAARToLYbMA80bHilZK5AzpYoTVH9GgfruLeq/ljJJAyh33vQgk26VX63mBIlp7cgxMx96T2iSqUuNbylXHgEOhPXMytv7FT4JcxMhNIRCq9YnsS8nD7+6GrJ7tSnochTauXs3OrM8bTA0AgZfj0PrC8aDZRCEShPU9QEjGTrtIX5AVcRoP01UInk1JWfQIBk1x5WPKYUDXQIrZPyLkWJ0Y6H7qcLKyBmDqTrEuMZ6fi9zcpEFkkg3wyC9ERr/UmVx xerus@goishi"
                        },
                        "meta": {
                            "schema_version": "1"
                        },
                        "tainted": false
                    },
                    "deposed": [],
                    "provider": "provider.aws"
                },
```

Vous pouvez vois le contenu de la ressources avec l'ensemble des informations qui sont dans **AWS**. Lors de la destruction des clés le fichier représente encore l'état de ce qui est dans **AWS** . [states/terraform-destruction-key.tfstate](./terraManifest/02-use-case/states/terraform-destruction-key.tfstate)

```
{
    "version": 3,
    "terraform_version": "0.11.10",
    "serial": 2,
    "lineage": "1f6a55a0-6cdb-e503-b400-b1086ab31a66",
    "modules": [
        {
            "path": [
                "root"
            ],
            "outputs": {},
            "resources": {},
            "depends_on": []
        }
    ]
}

```
 


### Création du réseau

Nous avons à présent les clés ssh qui nous servirons pour établir des connexions aux serveurs EC2, mais ces derniers doivent être présent dans un réseau. Nous pourrions simplement les définir dans le réseau par défaut, mais ce serait moins drôle !!


#### Creation des 2 sous réseaux et détermination du VPC

Nous allons avoir 2 subnets :

    * Serveur web : 172.31.60.0/27
    * Serveur bd : 172.31.50.0/27

Dans AWS les subnets sont obligatoirement dans un VPC , par défault AWS vous en fournit un . Je vais faire simple pour ce point je vais utiliser celui déjà disponible . Voici une représentation du réseau :

![](./imgs/architecture-overview-Network-overview.png) 

Éditons le fichier afin d'avoir les instructions suivante : 

```

resource "aws_subnet" "web-public-2a" {
    cidr_block = "172.31.60.0/27"
    availability_zone = "${var.aws_region}a"
    vpc_id     = ???????

    tags {
        Name = "Web"
    }
}

resource "aws_subnet" "bd-private-2a" {
    cidr_block = "172.31.50.0/27"
    availability_zone = "${var.aws_region}a"
    vpc_id     = ????????
    tags {
        Name = "BD"
    }
}
```

La documentation pour la création d'un subnet est disponible ici : [aws_subnet](https://www.terraform.io/docs/providers/aws/d/subnet.html).
Ici j'ai eu un problème , la ressource aws\_subnet demande le numéro **ID** du VPC , il n'est PAS possible de définir le nom du VPC. Ceci est représenté par l'entré **vpc\_id**. Malheureusement le numéro du VPC **id** change d'une région à l'autre même pour le vpc par défaut , voici quelque copie d'écran :

![](./imgs/08-aws-vpc-oregon.png)
![](./imgs/08-aws-vpc-ohio.png)
![](./imgs/08-aws-vpc-paris.png)

Donc 2 options s'offre à nous, l'objectif est de   

1. **la mauvaise** : écrire le numéro du VPC manuellement qui est lié à la région donc vpc-074b136e , par example . Ceci est vraiment problématique , car ceci sous tend que votre manifeste ne peux être exécuter QUE dans une régions définie.
2. **la bonne** : Extraire dynamiquement l'ID du vpc avec une requête :) .

Bon je pense qu'il est claire l'option choisie :D . Nous allons donc faire une requête pour avoir le **VPC** par default :

```
 # Get default VPC
resource "aws_default_vpc" "default" {
    tags {
        Name = "Default VPC"
    }
}

``` 

Avec cette instruction nous allons extraire l'information de ce VPC et nous pourrons utiliser cette ressource pour allimenter le paramètre **vpc\_id**, comme ceci : 

```
vpc_id     = "${aws_default_vpc.default.id}"
```

Nous avons la ressource de type **aws_default_vpc** avec le nom **default** qui à l'attribut **id** de disponible , donc pour regrouper l'ensemble : **aws_default_vpc.default.id**. J'ai insisté un peu sur le fichier d'état, mais c'est exactement le genre d'information que vous pouvez extraire de ce dernier pour savoir les attributs disponible.

Donc au finale :

```
 # Get default VPC
resource "aws_default_vpc" "default" {
    tags {
        Name = "Default VPC"
    }
}

resource "aws_subnet" "web-public-2a" {
    cidr_block = "172.31.60.0/27"
    availability_zone = "${var.aws_region}a"
    vpc_id     = "${aws_default_vpc.default.id}"

    tags {
        Name = "Web"
    }
}

resource "aws_subnet" "bd-private-2a" {
    cidr_block = "172.31.50.0/27"
    availability_zone = "${var.aws_region}a"
    vpc_id     = "${aws_default_vpc.default.id}"
    tags {
        Name = "BD"
    }
}

```

Nous allons faire la visualisation des activités avec l'option **plan**.

```
$ terraform plan 
```

Vous avez le contenu dans le fichier [plan-network.plan](./terraManifest/02-use-case/plans/plan-network.plan).
À la lecture du fichier vous constaterez que vous avez 5 nouvelles ressources créés , nous avons :

* les 2 clés SSH , nous les avions destruites lors de la dernière commande
* les 2 sous réseaux 
* le VPC qui sera détecté / initialisé comme ressource pour ce manifestes

Nous passons donc à l'application de la configuration .

```
$ terraform apply
[ ... ]
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```

En allant sur la console, vous constaterez que les subnets furent créeés : [subnet AWS](https://us-west-2.console.aws.amazon.com/vpc/home?region=us-west-2#subnets:sort=SubnetId).

![](./imgs/08-aws-subnet-created.png)

Ainsi que le VPC [vpc AWS](https://us-west-2.console.aws.amazon.com/vpc/home?region=us-west-2#vpcs:sort=VpcId)

![](./imgs/08-aws-vpc-created.png)

Voilà pas plus compliqué que cela :D.

##### Visualisation fichier d'état 

Je vais encore prendre le temps de parler du fichier d'état , peut-être pour la dernière fois mais je trouve très interaissant de voir les options qui s'offre à nous . J'ai fait une copie du fichier disponible [terraform-create-vpc-subnet.tfstate](./terraManifest/02-use-case/states/terraform-create-vpc-subnet.tfstate).

Si nous reprenons notre VPC : 

```
                "aws_default_vpc.default": {
                    "type": "aws_default_vpc",
                    "depends_on": [],
                    "primary": {
                        "id": "vpc-ec488994",
                        "attributes": {
                            "arn": "arn:aws:ec2:us-west-2:964887612364:vpc/vpc-ec488994",
                            "assign_generated_ipv6_cidr_block": "false",
                            "cidr_block": "172.31.0.0/16",
                            "default_network_acl_id": "acl-48075f30",
                            "default_route_table_id": "rtb-83cf6df8",
                            "default_security_group_id": "sg-7dbf780f",
                            "dhcp_options_id": "dopt-087d8370",
                            "enable_classiclink": "false",
                            "enable_classiclink_dns_support": "false",
                            "enable_dns_hostnames": "true",
                            "enable_dns_support": "true",
                            "id": "vpc-ec488994",
                            "instance_tenancy": "default",
                            "ipv6_association_id": "",
                            "ipv6_cidr_block": "",
                            "main_route_table_id": "rtb-83cf6df8",
                            "tags.%": "1",
                            "tags.Name": "Default VPC"
                        },
                        "meta": {
                            "schema_version": "1"
                        },
                        "tainted": false
                    },
                    "deposed": [],
                    "provider": "provider.aws"
                },
 
```

Nous retrouvons notre variable : **aws_default_vpc.default.id** avec la valeur **vpc-ec488994** .
Nous aurions pu avoir d'autre valeur telle que le segment réseaux **cidr_block**, nous allons voir cette utilisation dans quelques instants avec la configuration des règles de firewall. Il n'est pas facile d'avoir l'ensemble des informations disponible, mais avec ce fichier d'état ceci vous donne l'information exacte pour VOTRE utilisation. Voilà pourquoi j'insiste autant sur ce point , car c'est une source d'information non négligeable.

