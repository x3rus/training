
## Amélioration 

Nous avons un environnement de travail convenable, nous cliquons sur le bouton il y a une validation si le build est requis en relation au commit qui furent réalisé. Nous sommes en mesure de définir un numéro de build et de réaliser la compilation de notre conteneur , il n'y a pas d'erreur si le répertoire fournit n'est pas bon , mais dans la situation présente un conteneur valide sera régulièrement recompilé puis transmis au docker registry. Est-ce critique assurément pas car comme chaque layer est réutilisé il n'y aura à peu prêt de transfert. Cependant pour l'exercice, ne serait t'il pas mieux de valider si le conteneur avec le numéro de commit est déjà présent ? 
Bien entendu vous pourriez faire comme lors de ma première présentation commiter un fichier de configuration du Jenkins qui conserve le numéro de build de la dernière compilation. Mais c'est pas idéal car je n'aime pas le fait que le système de build commit dans le contrôleur de révision du projet , les 2 fonctionnent de pair mais sont indépendant. 

### Transférer l'image avec le numéro de commit

Procédons à l'ajout de l'image docker avec le numéro du commit en plus de la version "latest".

J'ai modifier le fichier de Makefile dans le répertoire du conteneur afin d'avoir une nouvelle définition, voici les sections ajouter :

```bash

 # Quelques variables au début 
DCK-COMPOSE-MAIN-DCK = x3-webdav
IMAGE-REMOTE-NAME = harbor.x3rus.com/xerus/x3-webdav
GIT-COMMIT-HASH := $(shell git rev-parse --short HEAD)

 # instruction de compilation du latest et ajout du tag pour le latest
build-latest:
    docker-compose build 
    docker tag ${IMAGE-REMOTE-NAME}:latest ${IMAGE-REMOTE-NAME}:${GIT-COMMIT-HASH}

 # pousse les 2 images vers le registry
push-to-registry:
    docker push ${IMAGE-REMOTE-NAME}
    docker push ${IMAGE-REMOTE-NAME}:${GIT-COMMIT-HASH}

```

Je relance le build et voilà j'ai mes 2 images sur le registry docker.

![](./imgs/21a-job-dockers-build-validate-push-setup-with-push-registry-Visualisation-dck-registry.png)


### Validation de la présence du conteneur avec le numéro de tag

Nous sommes donc en mesure de pousser sur le serveur de registry le conteneur avec le numéro du commit ID. Comme nous avons l'information nous seront en mesure de valider la présence pour savoir si nous devons construire la nouvelle image. J'ai fait beaucoup de recherche sur internet pour être en mesure de communiquer avec le registry et valider si le tag est présent. J'ai probablement mal cherché ou pas utilisé les bon **buzz** word mais j'ai pas réussi à avoir le résultat voulu avec Curl. Toujours des problèmes d'authentification pour avoir les tags , finalement j'ai vu dans le projet Github de **harbor** un script python qui réalise exactement ce que je désire. Est-ce que ceci est fonctionnel uniquement avec Harbor ? À valider pour le moment je procède avec ce mécanisme et nous verrons par la suite, lorsque j'utiliserai autre chose :D .

Voici un exemple d'utilisation :

```
$ git remote -v
origin  https://github.com/vmware/harbor.git (fetch)

$ cd harbor/contrib/registryapi

$ ./cli.py --username BobLeRobot --password MonSuperPassword --registry_endpoint https://harbor.x3rus.com tag list --repo xerus/x3-webdav                  {                                      
    "name": "xerus/x3-webdav",         
    "tags": [                          
        "d5605b2",                     
        "latest"                       
    ]                                  
}              
```

Nous allons donc l'intégrer dans l'ensemble du processus.

Référence intéressante : https://support.cloudbees.com/hc/en-us/articles/230610987-Pipeline-How-to-print-out-env-variables-available-in-a-build

## Stop , analyse et reconcidération de la configuration

Bon, comme toujours la démonstration ici est un travail en mouvement , je pars d'une idée et je la bâti pour répondre à un "besoin" ou disons que je me crée un cas d'école pour monter en compétence. Bien entendu l'ensemble de cette apprentissage est bénéfique et me permet de le réutilisé quand le contexte est plus chaud , mais l'objectif est avant tous de m'amuser et découvrir . 

Bon plusieurs problème sont présent dans la solution actuelle et je désire les corriger , voici les points et les solutions proposé :

1. Le build ne supporte, réellement, que la compilation d'une image , il est possible d'en passé plusieurs mais la gestion d'erreur est inadéquate. Il est important de corriger ce problème. 
2. Aujourd'hui le Makefile est self content mais si nous désirons mettre d'autre fonctionnalité dans le Makefile des scripts seront requis. Je ne veux pas avoir des scripts dans le dépôt des projets dockers et des scripts dans le dépôts scripts. Voir pour mettre le système de submodules de git afin d'inclure le dépôt scripts. L'objectif est que le Makefile soit fonctionnel avec ou SANS Jenkins.
3. Le transfère de l'image vers le registry docker n'est pas bonne , actuellement l'entrée dans le docker-compose ne supporte qu'une image il est possible de modifier le Makefile mais l'ensemble de l'information est déjà dans le docker-compose.yml . Il serait plus adéquat d'utiliser l'information présente, surtout s'il y a plusieurs image pour un même service.
4. Il n'y a pas de validation si l'image fut déjà compiler , nous pourrions optimiser le temps de CPU afin que si l'image est déjà dans le registry avec le numéro hash git , ne pas perdre du cycle de CPU et utiliser de la bande passante.

Il y a probablement plusieurs autre point d'amélioration que nous pourrions apporter , mais c'est déjà pas mal et je les découvrirai lors de la réalisation des 4 point ci-dessus .

### Support pour le build, multi-conteneur

J'ai principalement modifié le script python de validation du build afin que le retour soit sous le format d'une chaîne de caractère sous le format : 

```
 # originalement
 ['x3-webdav','x3-snmpd']

 # suite à la modification
 x3-webdav,x3-snmpd
```

Ceci m'a permit de capitaliser sur la fonction **loop\_container\_make** qui avait le support pour ce format. J'ai aussi ajouté un flag que l'on passe au script pour indiquer que ceci est appelé par Jenkins. Ceci me permet d'avoir une gestion du code d'erreur différente selon le requis, ainsi que la gestion des message affiché. 

Voici le résultat du pipeline :

```

def int loop_container_make(list,target) {

    for (def dockerDir : list.split(",")  ) {
           dir("dockers")
           {
                sh (script: "make -C ${dockerDir} ${target}")
           }
    }
} 
    
pipeline {

    agent { node { label 'docker' } }
    
    environment {
        CONTINUE_STATUS = true
        LST_DCKs = ""
    }

     stages {
         stage('GitExtraction') {
             steps {
                dir('dockers') {
                    checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GitLab-BobLeRobot-access', url: 'http://gitlabsrv/Devops/dockers.git']]])
                }
                dir('scripts') {
                    git credentialsId: 'GitLab-BobLeRobot-access', url: 'http://gitlabsrv/Devops/scripts.git'
                }
            } // End Steps
         } // End Stage GitExtraction

         stage('BuildDockers') {
             when {
                expression {
                    dir('dockers') {
                        // Version avec le output
                        // LST_DIR = sh( returnStdout: true,
                        //        script: 'python3 ../scripts/jenkins/gitBuildValidation.py --include-dir $DOCKER_NAME --exclude-user BobLeRobot' )
                            
                        // Version avec le code de retour
                        LST_DCKs = sh( returnStdout: true,
                                        script: 'python3 ../scripts/jenkins/gitBuildValidation.py --jenkins --include-dir $DOCKER_NAME --exclude-user BobLeRobot' 
                                       )
                            
                        // Debug mod pour comprendre 
                        println "return list dockers " 
                        println "aa"+LST_DCKs+"aa"
                        // Corrige le comportement du bash pour qui : 
                        // 0 ==  True 
                        // autre == False :P
                        
                        // ATTENTION : 
                        // dans le retour la variable contient un espace a la fin ...
                        if ( LST_DCKs.trim() == "No_Docker_img_to_build") {
                            CONTINUE_STATUS = false
                            return false
                        } else {
                            return true
                        }
                    }
                    
                }
             } // END When  

            steps {
                    loop_container_make(LST_DCKs.trim(), 'build-4-test')
            }

         } // END Stage 'BuildDockers'
        stage('ValidationConteneur') {
             when {
                expression {
                    return CONTINUE_STATUS
                }
              }
            steps {
                loop_container_make(LST_DCKs.trim(), 'test-build')
            }
        } // END Validationconteneur
        stage('PushImgRegistry') {
              when {
                expression {
                    return CONTINUE_STATUS
                }
              }
            steps {
                // Setup Docker Authentication with user BobLeRobot
                // fonctionne PAS car ecriture en dehors du Workspace
                // writeFile file: '~/.docker/config.json',
                //                 text: '''
                //                {                                      
                //                "auths": {                     
                //                    "harbor.x3rus.com": {  
                //                        "auth": "Qm9iTGVSb2JvdDpUYXNvZXVyMTIz"                 
                //                    }                      
                //                }                              
                //              }'''
                
                loop_container_make(LST_DCKs.trim(), 'buildLatestPush')
            }
        } // END stage PushImgRegistry
     } // End StageS
    
} // END pipeline

```

### Traitement des conteneurs indépendamment de Jenkins

Telle que mentionné je désire que l'utilisation des fichiers __Makefile__ dans le dépôt du conteneur fonctionne que nous utilisions Jenkins ou pas . Cependant si nous désirons mettre en place un système de validation avant l'envoie vers le docker registry il faudra utiliser des scripts. Je ne désires pas avoir des scripts dans le dépôt docker et dans Jenkins . 

* Donc je désires que l'ensemble des scripts soit contenu dans le dépôt script
* Je désire que le dépôt docker soit auto suffisent  mais qu'il est les scripts de l'autre dépôt
* Si j'ai un script spécifique au docker je désire que mon dépôt script en est un copie synchronisé.

La seul solution à ce problème est d'utiliser le concept de [submodule dans git](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

Voici un exemple de la création du submodule dans le dépôts Dockers


```bash
$ git submodule add http://tboutry@git.training.x3rus.com/Devops/scripts.git                                                                             
$ git -C scripts config core.sparseCheckout true                          
$ echo 'harbor/*' >>.git/modules/scripts/info/sparse-checkout             
$ git submodule update --force --checkout scripts/                        
$ ls scripts/                     
```

Ici en plus de la mise en place j'ai limité l'extraction du contenu du répertoire script , ce dernier ne contient QUE le répertoire **harbor** et pas **jenkins** . Cependant lorsque je réalise un nouveau **clone** du dépôt la configuration __sparse-checkout__ n'est pas conservé :(. 

```bash
$ git clone --recursive http://tboutry@git.training.x3rus.com/Devops/dockers.git
Cloning into 'dockers'...
Password for 'http://tboutry@git.training.x3rus.com': 
remote: Counting objects: 314, done.
remote: Compressing objects: 100% (161/161), done.
remote: Total 314 (delta 169), reused 276 (delta 143)
Receiving objects: 100% (314/314), 81.96 KiB | 27.32 MiB/s, done.
Resolving deltas: 100% (169/169), done.
Submodule 'scripts' (http://tboutry@git.training.x3rus.com/Devops/scripts.git) registered for path 'scripts'
Cloning into '/home/xerus/tmp/dockers/scripts'...
Password for 'http://tboutry@git.training.x3rus.com': 
remote: Counting objects: 67, done.        
remote: Compressing objects: 100% (41/41), done.        
remote: Total 67 (delta 29), reused 57 (delta 23)        
Submodule path 'scripts': checked out '5d2e054d2907429ad6cabfaaa1329ad05fc8f9f0'

$ ls dockers/scripts/
harbor  jenkins  README.md
```

Je met l'instruction **--recursive** afin que les sous modules soit extrait aussi , mais comme le représente la commande ls à la fin nous avons l'ensemble.
Honnêtement pour le moment c'est moins grave à mes yeux que d'avoir une duplication ou une séparation des scripts. 


Backup du pipeline "final" :

```
def int loop_container_make(list,target) {

    for (def dockerDir : list.split(",")  ) {
           dir("dockers")
           {
                sh (script: "make -C ${dockerDir} ${target}")
           }
    }
} 
    
pipeline {

    agent { node { label 'docker' } }
    
    environment {
        CONTINUE_STATUS = true
        LST_DCKs = ""
        SCRIPT_EXTRACT_DOCKER_COMPOSE = '"../scripts/dockers/extractImgDockerCmp.py"'
        SCRIPT_CHECK_DOCKER_REGISTRY = '"../scripts/dockers/dockerRegistryValidation.py"'
        SCRIPT_HARBOR = '"../scripts/harbor/harbor_cli.py"'
    }

     stages {
         stage('GitExtraction') {
             steps {
                dir('dockers') {
                    checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'SubmoduleOption', disableSubmodules: false, parentCredentials: true, recursiveSubmodules: true, reference: '', trackingSubmodules: false]], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GitLab-BobLeRobot-access', url: 'http://gitlabsrv/Devops/dockers.git']]])
                }
                dir('scripts') {
                    git credentialsId: 'GitLab-BobLeRobot-access', url: 'http://gitlabsrv/Devops/scripts.git'
                }
            } // End Steps
         } // End Stage GitExtraction

         stage('BuildDockers') {
            when {                    
                expression {           
                    dir('dockers') {   
                        // Version avec le output                              
                        // LST_DIR = sh( returnStdout: true,                   
                        //        script: 'python3 ../scripts/jenkins/gitBuildValidation.py --include-dir $DOCKER_NAME --exclude-user BobLeRobot' )           

                        // Version avec le code de retour                      
                        LST_DCKs = sh( returnStdout: true,                     
                                        script: 'python3 ../scripts/jenkins/gitBuildValidation.py --jenkins --include-dir $DOCKER_NAME --exclude-user BobLeRobot'                                    
                                       )                                       

                        // ATTENTION : 
                        // dans le retour la variable contient un espace a la fin ...                                                                         
                        if ( LST_DCKs.trim() == "No_Docker_img_to_build") {    
                            CONTINUE_STATUS = false                            
                            return false                                       
                        } else {    
                            
                            // Valide si l'image est encore dans le docker registry 
                            LST_DCKs = sh( returnStdout: true,                 
                                        script: 'python3 ../scripts/jenkins/dockerAlreadyInRegistry.py --jenkins -g ' + '--script-harbor=' + SCRIPT_HARBOR + ' --script-extCmpInfo=' + SCRIPT_EXTRACT_DOCKER_COMPOSE + ' --script-checkRegistry=' + SCRIPT_CHECK_DOCKER_REGISTRY  + ' -D  "' +  LST_DCKs.trim() + '"' )                
                            
                            if ( LST_DCKs.trim() == "No_Docker_img_to_build") {
                                CONTINUE_STATUS = false                        
                                return false                                   
                            } else {   
                                return true                                    
                            }          
                        }              
                    }                  
                  
                }                      
            } // END When             


            steps {
                    loop_container_make(LST_DCKs.trim(), 'build-4-test')
            }

         } // END Stage 'BuildDockers'
        stage('ValidationConteneur') {
             when {
                expression {
                    return CONTINUE_STATUS
                }
              }
            steps {
                loop_container_make(LST_DCKs.trim(), 'test-build')
            }
        } // END Validationconteneur
        stage('PushImgRegistry') {
              when {
                expression {
                    return CONTINUE_STATUS
                }
              }
            steps {
                // Setup Docker Authentication with user BobLeRobot
                // fonctionne PAS car ecriture en dehors du Workspace
                // writeFile file: '~/.docker/config.json',
                //                 text: '''
                //                {                                      
                //                "auths": {                     
                //                    "harbor.x3rus.com": {  
                //                        "auth": "Qm9iTGVSb2JvdDpUYXNvZXVyMTIz"                 
                //                    }                      
                //                }                              
                //              }'''
                
                loop_container_make(LST_DCKs.trim(), 'buildLatestPush')
            }
        } // END stage PushImgRegistry
     } // End StageS
    
} // END pipeline
```
