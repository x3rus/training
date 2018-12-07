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

**VERSION FINAL FICHIER** : [02-use-case.tf](https://github.com/x3rus/training/blob/c57b9d1587be7f9fc0805d754c31ba511a2e45b8/terraform/terraManifest/02-use-case/02-use-case.tf)

#### Creation des règles de firewall (security group)

Nous sommes à l'étape d'avoir nos segments réseaux, mais depuis déjà plusieurs années avoir des segments réseaux non sécurisé par un firewall n'est PLUS une option. Que nous soyons dans les nuages ( cloud ) ou dans un environnements interne c'est la même situation. Nous allons donc réaliser une configuration des security group , terme utilisé par AWS pour identifier les règles. Je vous invite à lire sur sujet si vous n'avez pas suivie la formation AWS 101 : [security group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html).

Reprenons notre flux réseau présenté un peu plus tot : 

![](./imgs/architecture-overview-network-flow.png)

Bon rien d'extraordinaire dans le schéma ci-dessus :

* Disponible depuis internet 
    * port 80 : afin de rendre disponible le site web pour l'ensemble des utilisateurs
    * port 22 : afin de permettre à l'administrateur depuis son bureau , sous-sol , la plage :P , de gérer ses serveurs
* Disponible à l'interne uniquement 
    * port 3306 : UNIQUEMENT  le serveur web peut établir une connexion au service SQL sur les serveurs de Base de données. L'admnistrateur devra établir une connexion ssh sur le serveur web ou de BD pour faire des changements BD.
* Flux vers l'exterieur :
    * Ici c'est pas super :P , honnêtement il y a place à amélioration , J'ai ouvert l'ensemble des communications vers internet. Dans un monde idéal je limiterai les communications possibles. Mieux encore j'utiliserai un AWS VPC gateway pour que les serveurs n'est PAS d'adresse IP publique et utilise un gateway pour communiquer sur internet. L'objectif étant d'apprendre terraform , on repassera pour cette partie :P.


Rapidement pour rafraichir la mémoire à tous le monde , les security groups sont donc les règles de firewall de AWS. Par défaut, l'ensemble des communications sont bloqué lors de la création d'un security groupe. Vous ne pouvez définir QUE des règles d'authorisation aucune règles de REJECT ou DROP est possible ! Il est possible d'assigner plusieurs sécurity group à une machine EC2, il y a une limitation mais très haute. 

Dans cette logique , je vais donc créer des règles de firewall générique que j'assignerai au instance EC2 par la suite. 


La ressource terraform pour faire cette opération est : [aws_security_group](https://www.terraform.io/docs/providers/aws/r/security_group.html)

Commençons avec la règle qui nous permettre de réaliser l'administration des machines, car s'il y a un problème avec une instance EC2 , que ce soit avec une règle de Firewall ou autre la première choses que nous voudrons faire est de ce connecter sur la machine.

Vous pouvez voir les security groupes disponible sur la console AWS [security group aws](https://us-west-2.console.aws.amazon.com/vpc/home?region=us-west-2#SecurityGroups:sort=groupId) .

![](./imgs/09-aws-security-group-view.png)

Trève de discution ... 

##### Règle général ( access à distance + communication vers internet )

```
resource "aws_security_group" "allow_remote_admin" {
  name        = "allow_remote_admin"
  description = "Allow ssh and RDP inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_remote_admin"
  }
}
```

Analysons un peu le contenu  :

* resource “aws_security_group” “allow_remote_admin” : le type de ressource **aws_security_group** et le nom de la ressource associé **allow_remote_admin**
* name = "allow_remote_admin" : Nous assignons le nom qu'il aura dans AWS , le nom précédent est uniquement pour le manifeste de terraform.
* description : Une description encore une fois pour le visuel dans la console AWS et pratique pour le manifest lors de la consultation. Ne pas dénigrer ce point.

* Nous passons à la définition de règles , dans l'exemple ci-dessus nous ajoutons des règes pour les communications entrante.

* ingress : Définition des règles de firewall en **entré (in)** qui suront **ACCEPTÉS** 
    * from_port = 22 : Nous acceptons depuis le port 22 
    * to_port = 22 : Jusqu'au port 22 , bon c'est pas révolutionnaire comme notation , j'en convient :P , je n'ai que 1 port que je veux ouvrir.
    * protocol = "tcp : Le protocol ici TCP mais nous aurions pu avoir du UDP aussi
    * cidr_blocks = ["0.0.0.0/0"] : le range d'adresse IP qui sera accepté , dans notre cas l'ensemble d'internet donc 0.0.0.0

* Je fais la même opération pour le port 3389/TCP pour le port RDP windows. Ici ceci c'est discutable , j'ai préférer faire un groupe de règle de gestion des systèmes pour que ce soit plus facile à gérer. De plus ceci m'a permit de valider la mise en place de règle multiple dans un groupe .
* TAGS : si vous avez utilisez un peu AWS , le système de tags est essentiel pour être en mesure de faire une gestion efficace. Que nous parlions d'organisation ou pour l'ensemble du processus de facturation . J'assigne donc un nom pour le moment simplement.

Telle que mentionné précédement , par défaut l'ensemble des communications sont bloqués , donc si vous désirez être en mesure d'allez sur internet , vous devrez ouvrir la communication. Quand je parle d'aller sur internet , ceci couvre l'installation d'application aussi. 

Mettons donc en place la règle d'ouverture vers le monde extérieur , **ATTENTION** je suis conscient que la règle ci-dessous est très large , pour rappel l'objectif est d'apprendre terraform. La restriction de l'applicatif dans un mode optimal n'est pas l'objectif primaire.

```
resource "aws_security_group" "allow_external_communication" {
  name        = "allow_external_communication"
  description = "Allow system reach other servers"

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_external_comm"
  }
}
```

Nous retrouvons sensiblement les mêmes entrés , le changement est que nous n'avons pas l'instruction **ingress**, mais **egress** .

* egress : Définition des règles de firewall en **sortie (ext)** qui seront **ACCEPTÉS**
    * from_port = 0 : depuis le port 0 
    * to_port : 65535 :  jusqu'au port 65535 , ceci couvre l'ensemble de la plage TCP 
    * protocol = tcp : comme pour la communication entrente 
    * cidr_blocks = ["0.0.0.0/0"] = la plage d'adresse IP vers où la communication est permisent, 0.0.0.0 donc l'ensemble d'internet.

Avec ces 2 règles si vous démarrez une instance EC2 vous pourrez , vous y connecter et parcourir l'internet sans problème.


##### Règle applicative

Passons maintenant aux règles proche de l'application , débutons avec la règle pour l'access au service web : http et http**s**.

```
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web traffic to server"

  ingress {
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_web"
  }
}
```

Ceci est très proche de la règle pour l'accès au service ssh et RDP , je ne vais donc pas reprendre l'explication.

Maintenant la règle pour l'accès à la base de donnée 

```
resource "aws_security_group" "allow_mysql_internal" {
  name        = "allow_mysql_internal"
  description = "Allow Mysql connexion from web server"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.web-public-2a.cidr_block}"]
  }

  tags {
    Name = "allow_mysql_internal"
  }
}
```

Pour cette règles il y a une particuliarité importante , l'entré **cidr_blocks** , je ne veux pas que l'accès à la base de donnée soit possible depuis l'ensemble d'internet mais uniquement depuis le réseau des serveurs webs. J'ai donc limité l'accès à la plage d'adresses ip de se segment réseau. J'aurai pu simplement écrire 172.31.60.0/27 , cependant j'essaye d'avoir quelques choses de plus dynamique. Avec cette notation si le segment change les règles de firewall suivront. 

Au risque d'être insistant cette information je l'ai extraite du fichier de states **terraform.tfstate** 

```
"aws_subnet.web-public-2a": {
                    "type": "aws_subnet",
                    "depends_on": [
                        "aws_default_vpc.default"
                    ],
                    "primary": {
                        "id": "subnet-06a4165fea30b8b51",
                        "attributes": {
                            "arn": "arn:aws:ec2:us-west-2:964887612364:subnet/subnet-06a4165fea30b8b51",                                                     
                            "assign_ipv6_address_on_creation": "false",
                            "availability_zone": "us-west-2a",
                            "cidr_block": "172.31.60.0/27",
                            "id": "subnet-06a4165fea30b8b51",
                            "map_public_ip_on_launch": "false",
                            "tags.%": "1",
                            "tags.Name": "Web",
                            "vpc_id": "vpc-ec488994"
                        },
                        "meta": {
                            "e2bfb730-ecaa-11e6-8f88-34363bc7c4c0": {
                                "create": 600000000000,
                                "delete": 600000000000
                            },
                            "schema_version": "1"
                        },
                        "tainted": false
                    },
                    "deposed": [],
                    "provider": "provider.aws"
                }

```

Visualisons les opérations : 

```
$ terraform plan 
```

Résultat disponible ici : [plans/plan-network-with-firewall.plan](./terraManifest/02-use-case/plans/plan-network-with-firewall.plan)

et nous appliquons le changement avec **terraform apply**

Résultat : [AWS security group](https://us-west-2.console.aws.amazon.com/vpc/home?region=us-west-2#SecurityGroups:sort=groupId) 

![](./imgs/09-aws-security-group-created.png)

Si nous regardons plus spécifiquement la règles pour mysql, nous voyons que la substitutions fut un success  :

![](./imgs/09-aws-security-group-created-mysql.png)

Le fichier d'état fut aussi sauvegardé : [states/terraform-create-vpc-subnet-and-firewall.tfstate](./terraManifest/02-use-case/states/terraform-create-vpc-subnet-and-firewall.tfstate)

### Création des instances EC2 ( VM ) 

Donc nous avons l'ensemble de la base mise en place :

* Clé ssh
* segment réseau
* règles de firewall

Mais tous ceci ne nous permet pas d'offrir un service nous avons besoin d'instances avec du CPU et de la mémoire , débutons avec la création de l'instance web , car il n'y en a qu'une.

Vous allez constater qu'il y a plusieurs variable dans la définition pour nous permettre de faire l'association avec les ressources préalablement créé.
Premièrement nous avons besoin de savoir le numéro **ID** de l'AMI que nous désirons utiliser . Nous avions déjà mis en place cette instruction lors du teste de communication. 

#### Extraction de l'AMI ID

D'une région à l'autre ( oregon, canada, Paris , ohio , ... ) les ID des AMI changent , en d'autre mot l'ID est couplé avec le datacenter, afin d'avoir un manifeste portable d'un datacenter à l'autre , nous récupérons l'information depuis AWS afin d'avoir la dernière version de l'AMI désiré .

```
 # Extract last AWS ubuntu AMazon Image (AMI)
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

Nous utilisons la ressource [aws_ami](https://www.terraform.io/docs/providers/aws/d/ami.html) qui nous permet d'extraire de l'information sur la **AMI**.
Avant d'allé plus loin sur l'explication, vous constaterez que le premier mot n'est pas **resource** mais **data** , prenons 2 secondes pour clarifier ce point bien qu'évident par la suite je préfère le mêtre en lumière.

La définition d'une [resource](https://www.terraform.io/docs/configuration/resources.html) telle que le mot l'indique vous permet de faire la création d'un élément dans AWS.
La définition d'un [data](https://www.terraform.io/docs/configuration/data-sources.html) vous permet de faire des requêtes à AWS pour extraire de l'informaton et les stockés dans des variables. Ceci offre la possibilité d'avoir un système plus dynamique dans la définition des entrés.
Je vous invite a cliquer sur les liens de la documentation pour la [resource](https://www.terraform.io/docs/configuration/resources.html) ou pour le [data](https://www.terraform.io/docs/configuration/data-sources.html) afin de voir l'ensemble des options. 

Donc regardons les paraètres de cette définition :

* **most\_recent** : nous indiquons que nous désirons la définition la plus récente
* **filter** basé sur le nom , ubuntu-xenial-16.04-amd64-server : Ceci nous permet de choisir le type de système que nous désirons avoir . Ok bon honnêtement cette partie je l'ai pris sur le net :P ( https://www.andreagrandi.it/2017/08/25/getting-latest-ubuntu-ami-with-terraform/ )

Mais bon ceci nous permet surtout de voir et comprendre , maintenant si nous allons la [console AWS](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;search=ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-;sort=name) , nous sommes en mesure de retrouver l'information : 

![](./imgs/10-aws-ami-review.png)

J'ai hésité mais je vais insisté encore sur le fichier d'état qui vous permet de connaître les autres paramêtre disponible pour les filtres.


#### Creation de l'instance EC2 web

Nous avons donc notre image de référence, nous allons poursuivre avec la création de notre première instance EC2. 
Nous allons schématiser l'opération que nous allons réaliser , car dans la prochaine étape nous allons couplé plusieurs configuration , voici donc une représentation graphique du résultat suite à la configuration.

![](./imgs/architecture-overview-Network-overview-web-ec2.png)

Donc nous avons :

* Le VPC globale 
* Nos 2 subnets , pour le web et pour la BD 
* Nous avons notre instance EC2 web nommé **web-terra** ( gros manque d'inspiration :P ) 
* Nous avons les règles de firewall assigné à cette instance allow_web +  allow_remote_admin + allow_external_communication

Nous avons fait la création de l'ensemble des dépendances préalablement, la création de l'instance sera le moment joindre l'ensemble des morceaux.
Voici la définition de la création de l'instance :

```
resource "aws_instance" "web-terra" {
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.ansible.key_name}"  # assign ssh ansible key
    subnet_id = "${aws_subnet.web-public-2a.id}"   

    associate_public_ip_address = true

    tags {
        Name = "web-terra"
        scope = "training"
        role = "web"
    }

    security_groups = [
        "${aws_security_group.allow_web.id}",
        "${aws_security_group.allow_external_communication.id}",
        "${aws_security_group.allow_remote_admin.id}"
    ]

    root_block_device = {
        delete_on_termination = true
        volume_size = 10 
    }

}
```


1. **resource "aws\_instance" "web-terra"** :  Nous définissons une ressource [aws_instance](https://www.terraform.io/docs/providers/aws/d/instances.html) , nous assignons le nom **web-terra** à cette ressource .
2. **ami = "\${data.aws\_ami.ubuntu.id}"** : Suite à l'extraction des informations sur l'AMI nous avons l'information de cette dernière dans la variable **data.aws\_ami.ubuntu** , comme la variable ami désire avoir un ID nous allons extraire la propriété **ID**. L'instance EC2 utilisera cette AMI comme point de départ.
3. **instance_type = "t2.micro"** : Le type d'instance AWS que nous désirons , ceci définie le CPU , la mémoire, etc.
4. **key_name = "\${aws\_key\_pair.ansible.key\_name}"** : Nous assignons la clé ssh de ansible préalablement créée dans AWS. Ceci nous permettra dans un second temps de faire la configuration de notre instance avec Ansible ou de simplement nous y connecter pour faire l'administration.
5. **subnet_id = "\${aws\_subnet.web-public-2a.id}"** : Nous assignons cette instance EC2 à un subnet , encore une fois le paramètre demande un ID , mais comme nous avons déjà la ressource en mémoire grâce à la création préalable. Nous prenons donc la ressource **aws\_subnet** avec le nom **web-public-2a** et le **id**. Une fois le concept saisie ça semble évident , mais bon ça prend un peu de temps.
6. **associate\_public\_ip\_address = true**  : J'assigne une adresse ip publique dynamiquement alloué par AWS.
7. **tags** : L'utilisation des tags est très important dans AWS ceci nous permet de regrouper des services , permet une facturation interne plus simple suite au ressource créés , etc . Dans la présentation ci-dessus je crée des tags arbitraire , telle que scope ou role.
8. **security\_groups** : Nous avons préalablement créer des sécurity groupe (firewall) , encore une fois nous devons utiliser les ID pour faire l'association , comme vous pouvez le constater j'assigne 3 security groups à l'instance pour couvrir l'ensemble des besoin de la machines.
9. **root\_block\_device** : Cette section nous permet de définir la taille du disque dur associé à l'instance, comme vous pouvez le voir j'ai mis le flag **delete\_on\_termination** afin de détruire le disque dur une fois la ressource détruite.


Vous voyez l'instance à l'ensemble de la configuration associer : Subnet , AMI , Firewall , clé ssh . Le subnet fut déjà associé au VPC préalablement.

J'attends déjà les mauvaise langue dire : 

> " oui c'est bien beau, mais l'ensemble des ressources sont crée dans le même manifeste facile de faire l'association, la partie réseau est géré par une autre équipe dans mon cas... bla bla bla :P ".

Ça bourdonne dans ma tête :P , je rigole , bien entendu ceci est une question ou situation légitime. 

Donc prenons le temps de répondre ou d'adresser cette problématique, pour ce faire j'aimerai vous rappeler que l'AMI ne fut PAS crée dans le manifeste. Pour l'ensemble des entités créer à l'exterieur du manifeste, vous aurez 2 options :

* Extraire l'ID manuellement et l'entrer dans votre manifeste , pratique pour faire des testes , mais la solution n'est pas idéal. En effet, même si la ressource porte le même nom dans l'ensemble des régions, elle aura un ID distinct résultat votre manifeste ne pourra être associé qu'a une région. De plus s'il y a suppression et recréation de la ressource même si elle a le même nom l'ID sera changé. Résultat évident votre manifeste ne fonctionnera plus.
* Utilisé le système **data** comme nous l'avons fait pour extraire l'AMI. Avec cette méthode bien entendu vous aurez besoin d'avoir un identifier afin de choisir la bonne ressource , que ce soit un nom , un tag , ... Par contre vous aurez beaucoup plus de flexibilité , car vous pourrez l'utiliser peut importe la région et s'il y a suppression et recréation de la ressource ceci fonctionnera encore.

Je pense que ma position est claire sur le choix de l'option :P , et je le rappel afin de vous aider faite la création d'une ressource bidon afin d'avoir un fichier d'état et constater les paramètres disponible. 

Réalisons la création de l'instance afin de voir le résultat :

```
$ terraform plan 
```

Résultat de la commande disponible dans le fichier [plan-network-creation-web-terra.plan](./terraManifest/02-use-case/plans/plan-network-creation-web-terra.plan)

Si vous regardez le fichier vous constaterez que j'avais oublié de faire la suppréssion des configurations réseaux, donc il n'y a l'ajout QUE de l'instance ec2

```
$ terraform apply 
[ ... ]
aws_instance.web-terra: Still creating... (10s elapsed)
aws_instance.web-terra: Still creating... (20s elapsed)
aws_instance.web-terra: Still creating... (30s elapsed)
aws_instance.web-terra: Creation complete after 35s (ID: i-0b16f40246a7998df)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Vous pouvez visualiser le résultat à dans la console AWS [list ec2 instance](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Instances:sort=instanceId)

![](./imgs/10-aws-ec2-web-terra-creation-1.png)

Ici nous avons aurons des coûts suite à la création je vais donc supprimer l'ensemble pour poursuivre la formation :

```
$ terraform destroy
```

Fichier contenenant la définition complète : [02-use-case.tf](https://github.com/x3rus/training/blob/7eb6ece3567dc610aec1e4d00e0ec90f20deccc5/terraform/terraManifest/02-use-case/02-use-case.tf)

#### Creation des instances EC2 BD

Nous avons fait la création de l'instance web , nous allons pouvoir poursuivre avec la définition des instances BD . Pour le moment lors de la création de nos instances EC2 aucune configuration OS n'est réalisé. Nous allons voir cette partie dans un second temps avec ansible, je ne le couvre pas tous de suie car pour être en mesure de faire une configuration complète nous avons besoin d'avoir de  l'information des autres instances. Un des requis pour faire la configuration du serveur web est de savoir l'adresse IP des serveurs BD pour faire la connexion :P.

Ce que nous désirons avoir :

* 2 serveurs Mysql
* Ces derniers doivent être dans le sebnet bd-private-2a
* La connexion au port Mysql ne doit être possible que depuis le segment INTERNE du serveur web

Voici donc une représentation graphique de la configuration avec l'ajout des base de données, nous pouvons constater que ceci ressemble beaucoup à la définition du serveur web, mais en double.

![](./imgs/architecture-overview-Network-overview-web-and-bd-ec2.png)

Voici le code :

```
resource "aws_instance" "db-terra" {
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.ansible.key_name}"  # assign ssh ansible key
    subnet_id = "${aws_subnet.bd-private-2a.id}"   

    associate_public_ip_address = true
   
    # Create 2 instance of the database
    count = 2

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

}
```


Vous pouvez visualiser sur github le fichier lors de ça rédaction :  [02-use-case.tf](https://github.com/x3rus/training/blob/42f399ae903c04329453aea6eb0a117023d514f11/terraform/terraManifest/02-use-case/02-use-case.tf)

Prenons le temps de lire la définition , premièrement le code ci-dessus couvre les 2 serveurs de base de donnés !! 
Nous utilisons la classe [aws\_instance](https://www.terraform.io/docs/providers/aws/r/instance.html) , comme lors de la création du serveur web.

1. **ami = "\${data.aws\_ami.ubuntu.id}"**  : Nous utilisons l'AMI extraite préalablement soir un ubuntu LTS 16.04
2. **instance\_type = "t2.micro"**  : Nous utilisons une instance de type t2, mon objectif est vraiment de faire la démonstration pas d'avoir de la performance.
3. **key_name = "\${aws\_key\_pair.ansible.key_name}"** : J'assigne la clé SSH qui nous servira par la suite pour ansible ou établir une connexion pour la gestion de la machine.
4. **subnet_id = "\${aws\_subnet.bd-private-2a.id}"** : J'assigne la machine EC2 dans le bon subnet  , ceci est identique à l'opération pour le serveur web avec juste le nom qui change.
5. **associate\_public\_ip\_address = true** : j'assigne une adresse ip publique , il y a 2 raison pour cela . Premièrement pour faire l'administration du système . Ici j'aurais pu simplement me dire que je vais passé par SSH via le serveur web. Cependant dans ma configuration minimaliste en place , si je n'assigne pas d'adresse ip publique à la machine cette dernière ne sera pas en mesure d'établie de connexion sur le web. Est-ce critique ? dans mon cas oui car je démarre avec une machine vanille , je ne serais pas en mesure de récupérer les logiciels pour faire leurs installations , particulièrement Mysql.
6. **count = 2** : J'indique avec cette ligne le nombre d'instance que je désire avoir , c'est grâce à cette ligne que nous aurons 2 serveurs BD et non juste 1 comme ce fut le cas lors de la création du serveur web.
7. **tags** et **Name = "db\${count.index}-terra"** : J'assigne des tags à l'instance , ici je met en évidence 1 tag , en fait c'est principalement la variable **\${count.index}** . Cette variable est incrémenté lors de la création et débute à 0 , donc le nom des instances BD seront : **db0-terra** et **db1-terra**.
8. **security_groups** : L'assignation des règles de firewall 
9. **root_block_device** : Définition d'un disque dur de 20 Gig , partant du principe que la Base de donnée grossira dans le temps , encore une fois ceci est plus un teste passant de la manipulation de l'espace disque d'une instance .

Comme vous pouvez le voir ceci est très similaire et grâce au mécanisme de count que j'ai 1 ou 20 instances identique ceci est très simple. L'utilisation de la variable **count** , nous permet d'identifier chacune d'entre elle.

C'est partie on va en premier lieu valider la configuration :

```
$ terraform plan
[ ... ]
  + aws_instance.db-terra[0]
      id:                                        <computed>
      ami:                                       "ami-076e276d85f524150"
      arn:                                       <computed>
      associate_public_ip_address:               "true"
      availability_zone:                         <computed>
      cpu_core_count:                            <computed>
      cpu_threads_per_core:                      <computed>
[ ... ]
  + aws_instance.db-terra[1]
      id:                                        <computed>
      ami:                                       "ami-076e276d85f524150"
      arn:                                       <computed>
      associate_public_ip_address:               "true"
      availability_zone:                         <computed>
      cpu_core_count:                            <computed>
      cpu_threads_per_core:                      <computed>
[ ... ]
Plan: 12 to add, 0 to change, 0 to destroy. 
```

Nous constatons que nous aurons 12 ressources de créés et nous voyons donc les 2 instances de base de donné avec l'index entre crochet .

```
$ terraform apply 
aws_instance.web-terra: Still creating... (10s elapsed)
aws_instance.db-terra.0: Still creating... (10s elapsed)
aws_instance.db-terra.1: Still creating... (10s elapsed)
aws_instance.web-terra: Still creating... (20s elapsed)
aws_instance.db-terra.1: Still creating... (20s elapsed)
aws_instance.db-terra.0: Still creating... (20s elapsed)
aws_instance.web-terra: Still creating... (30s elapsed)
aws_instance.db-terra[1]: Creation complete after 29s (ID: i-072c2f49ff9cb4f33)                                                                              
aws_instance.db-terra.0: Still creating... (30s elapsed)
aws_instance.web-terra: Still creating... (40s elapsed)
aws_instance.web-terra: Creation complete after 40s (ID: i-09a9adf3606c58381)
aws_instance.db-terra.0: Still creating... (40s elapsed)
aws_instance.db-terra.0: Still creating... (50s elapsed)
aws_instance.db-terra[0]: Creation complete after 51s (ID: i-0728346e3eceb4e94)

Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

```

Vous pouvez visualier le résultat , dans la [console aws](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Instances:sort=instanceId)

![](./imgs/11-aws-ec2-bd-creation.png)


Vous pouvez visualiser le fichier d'état : [terraform-creation-ec2s.tfstate](./terraManifest/02-use-case/states/terraform-creation-ec2s.tfstate)


Nous pouvons supprimer l'ensemble : 

```
$ terraform destroy
[ ... ]
Destroy complete! Resources: 12 destroyed.
```


#### Création d'une ressource et connexion ssh 

Bon, je m'excuse avec tous ça j'ai complètement oublié de faire la démonstration que l'instance été accessible et fonctionnel :P . Donc prenons 2 minutes pour faire cette démonstration . Comme vous avez pu le voir j'ai tout détruit préalablement si j'exécute la commande **terraform plan**

```
$ terraform plan 
[ ... ]
Plan: 12 to add, 0 to change, 0 to destroy.
```

Bon mais moi je veux juste une instance , avec l'ensemble de ces dépendances ... Pas de problème Terraform l'a pris en charge ce besoin :P.

```
$ terraform plan --target=aws_instance.web-terra
<= data.aws_ami.ubuntu
+ aws_default_vpc.default
+ aws_instance.web-terra
+ aws_key_pair.ansible
+ aws_security_group.allow_external_communication
+ aws_security_group.allow_remote_admin 
+ aws_security_group.allow_web
+ aws_subnet.web-public-2a

Plan: 7 to add, 0 to change, 0 to destroy.
```

Donc pour faire la création de la ressource aws_instance.web-terra , 7 ressources doivent être réalisé , 6 créer et 1 pour la recherche de l'AMI id.

Je vais faire donc apply : 

```
$ terraform apply --target=aws_instance.web-terra
```

Je suis allé sur la [console amazon](https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Instances:sort=instanceId) pour extraire l'adresse IP publique : 

![](./imgs/11-aws-web-publique-ip.png)

Établissons la connexion SSH 

```
$ ssh -i ssh-keys/ansible-user  ubuntu@34.219.211.56
ubuntu@ip-172-31-60-19:~$ sudo -l
Matching Defaults entries for ubuntu on ip-172-31-60-19.us-west-2.compute.internal:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User ubuntu may run the following commands on ip-172-31-60-19.us-west-2.compute.internal:
    (ALL : ALL) ALL
    (ALL) NOPASSWD: ALL

ubuntu@ip-172-31-60-19:~$ telnet google.com 80 
Trying 172.217.6.78...
Connected to google.com.
Escape character is '^]'.
GET /
HTTP/1.0 200 OK  
```

Donc la commande SSH fonctionne et nous avons bien internet 


### Suppression d'une ressource 

L'instruction **target** fonctionne aussi pour identifer uniquement une ressource , donc si je désire supprimer uniquement l'instance EC2 web que je viens tous juste de créer tous en conservant les configuration réseaux par example ... nous pouvons procéder ainsi : 

```
$ terraform destroy --target=aws_instance.web-terra 
Terraform will perform the following actions:

  - aws_instance.web-terra


Plan: 0 to add, 0 to change, 1 to destroy.
```

Uniquement 1 ressource supprimer , par le fait même si nous voudrions recréer l'instance l'ensemble des dépendances seront déjà présente.

```
$ terraform plan --target=aws_instance.web-terra 
[ ... ] 
Plan: 1 to add, 0 to change, 0 to destroy.

```
