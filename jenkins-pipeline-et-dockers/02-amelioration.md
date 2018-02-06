
## Amélioration 

Nous avons un environnement de travail convenable, nous cliquons sur le bouton il y a une validation si le build est requis en relation au commit qui furent réalisé. Nous sommes en mesure de définir un numéro de build et de réaliser la compilation de notre conteneur , il n'y a pas d'erreur si le répertoire fournit n'est pas bon , mais dans la situation présente un conteneur valide sera régulièrement recompilé puis transmis au docker registry. Est-ce critique assurément pas car comme chaque layer est réutilisé il n'y aura à peu prêt pas de transfert. Cependant pour l'exercice, ne serait t'il pas mieux de valider si le conteneur avec le numéro de commit est déjà présent ? 
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

## Stop !!! Analyse et reconcidération de la configuration

Bon, comme toujours la démonstration ici est un travail en mouvement , je pars d'une idée et je la bâti pour répondre à un "besoin" ou disons que je me crée un cas d'école pour monter en compétence. Bien entendu l'ensemble de cette apprentissage est bénéfique et me permet de le réutilisé quand le contexte est plus chaud , mais l'objectif est avant tous de m'amuser et découvrir . 

Bon plusieurs problème sont présent dans la solution actuelle et je désire les corriger , voici les points et les solutions proposé :

1. Le build ne supporte, réellement, que la compilation d'une image , il est possible d'en passé plusieurs mais la gestion d'erreur est inadéquate. Il est important de corriger ce problème. 
2. Aujourd'hui le Makefile est self content mais si nous désirons mettre d'autre fonctionnalité dans le Makefile des scripts seront requis. Je ne veux pas avoir des scripts dans le dépôt des projets dockers et des scripts dans le dépôts scripts. Voir pour mettre le système de submodules de git afin d'inclure le dépôt scripts. L'objectif est que le Makefile soit fonctionnel avec ou SANS Jenkins.
3. Le transfère de l'image vers le registry docker n'est pas bonne , actuellement l'entrée dans le docker-compose ne supporte qu'une image il est possible de modifier le Makefile mais l'ensemble de l'information est déjà dans le docker-compose.yml . Il serait plus adéquat d'utiliser l'information présente, surtout s'il y a plusieurs image pour un même service.
4. Il n'y a pas de validation si l'image fut déjà compiler , nous pourrions optimiser le temps de CPU afin que si l'image est déjà dans le registry avec le numéro hash git , ne pas perdre du cycle de CPU et utiliser de la bande passante.

Il y a probablement plusieurs autre point d'amélioration que nous pourrions apporter , mais c'est déjà pas mal et je les découvrirai lors de la réalisation des 4 point ci-dessus .

### (1) Support pour le build, multi-conteneur

J'ai principalement modifié le script python de validation du build afin que le retour soit sous le format d'une chaîne de caractère sous le format : 

```
 # originalement
 ['x3-webdav','x3-snmpd']

 # suite à la modification
 x3-webdav,x3-snmpd
```

Ceci m'a permit de capitaliser sur la fonction **loop\_container\_make** qui avait le support pour ce format. J'ai aussi ajouté un flag que l'on passe au script pour indiquer que ceci est appelé par Jenkins. Ceci me permet d'avoir une gestion du code d'erreur différente selon le requis, ainsi que la gestion des message affiché. 

Comme j'utilise le résultat (stdout) de la command __gitBuildValidation.py__ , je ne peux pas utiliser en même temps le code d'erreur de retour. Ceci est une limitation du système de Pipeline Jenkins. Donc pour palier ce problème je retourne le texte __No_Docker_img_to_build__ si aucun répertoire n'est à compiler.

```
if ( LST_DCKs.trim() == "No_Docker_img_to_build") {
    CONTINUE_STATUS = false
    return false
} else {
    return true
}
```

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
                            
                        // Version avec le code de retour
                        LST_DCKs = sh( returnStdout: true,
                                        script: 'python3 ../scripts/jenkins/gitBuildValidation.py --jenkins --include-dir $DOCKER_NAME --exclude-user BobLeRobot' 
                                       )
                            
                        // Debug mod pour comprendre 
                        println "return list dockers " 
                        println "aa"+LST_DCKs+"aa"
                        
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

### (2) Traitement des conteneurs indépendamment de Jenkins

Telle que mentionné je désire que l'utilisation des fichiers __Makefile__ dans le dépôt du conteneur fonctionne que nous utilisions Jenkins ou pas . Cependant si nous désirons mettre en place un système de validation avant l'envoie vers le docker registry il faudra utiliser des scripts. Je ne désires pas avoir des scripts dans le dépôt docker et dans Jenkins . 

* Donc je désires que l'ensemble des scripts soit contenu dans le dépôt script
* Je désire que le dépôt docker soit auto suffisent  mais qu'il est les scripts de l'autre dépôt
* Si j'ai un script spécifique au docker je désire que mon dépôt script en est un copie synchronisé.

La seul solution à ce problème est d'utiliser le concept de [submodule dans git](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

Voici un exemple de la création du submodule dans le dépôts Dockers


```bash
$ git submodule add http://tboutry@git.training.x3rus.com/Devops/scripts.git                                                                             
$ echo 'harbor/*' >>.git/modules/scripts/info/sparse-checkout             
$ git submodule update --force --checkout scripts/                        
$ ls scripts/                     
```

Ici en plus de la mise en place j'ai limité l'extraction du contenu du répertoire script , ce dernier ne contient QUE le répertoire **harbor** et pas **jenkins** . Cependant lorsque je réalise un nouveau **clone** du dépôt la configuration __sparse-checkout__ n'est pas conservé :(.  J'ai opté pour laisser tomber cette partie par la suite , car finalement c'est pas grave il y aura plus de scripts et c'est tout, l'effort n'en valait pas l'impact du résultat d'avoir tout !!

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

Je met l'instruction **--recursive** afin que les sous modules soit extrait aussi , mais comme le représente la commande **ls** à la fin nous avons l'ensemble. Honnêtement pour le moment c'est moins grave à mes yeux que d'avoir une duplication ou une séparation des scripts. 

### (3) Pousser l'ensemble des images au docker registry

Dans l'état actuelle de la configuration le contenu du Makefile est problématique voici la partie qui pousse le conteneur :

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

Donc j'ai la variable **IMAGE-REMOTE-NAME** qui définie l'image à pousser , donc avec un docker-compose.yml qui contient 1 conteneur ça va pas de problème, mais comme nous voulons utiliser le principe de docker à son maximum nous désirons segmenter nos conteneurs selon le service. Résultat nous allons devoir définir plusieurs variables pour faire l'exercice, ceci en soit est pas critique au jour 1 de la mise en place. 
Par la suite nous allons faire évoluer la solution définir plus de conteneur en relation et oublier d'ajuster le Makefile, nous le constaterons pas, car sur le poste de développement nous allons utiliser le docker-compose.yml et localement ça sera bon.

J'ai eu une grande période de réflexion sur le sujet, que faire ? Une chose est sur l'ensemble de l'information des conteneurs est contenu dans le docker-compose.yml , j'ai donc une source complète. Inutile de définir un autre fichier à côté pour l'exercice, par contre je ne peux PAS simplement faire un docker-compose push , car je veux que ce soit limité au conteneur de mon environnement "harbor.x3rus.com".

Maintenant que j'ai sous la main l'ensemble du dépôt git j'ai décidé de faire un script qui va consulter le fichier docker-compose.yml pour extraire les images dockers de mon domaine. 

Le nom du script [extractImgDockerCmp.py](https://raw.githubusercontent.com/x3rus/training/master/jenkins-pipeline-et-dockers/depot-dockers-pour-gitlab/scripts-projects/dockers/extractImgDockerCmp.py) .

Je vous laisserez lire le détail du script , rapidement si on fait un résumé : Le script permet 

* De lire un fichier docker-compose.yml (-f pour définir un autre nom ) 
* Depuis un répertoire nommé par défaut le répertoire local ( -d pour définir un autre répertoire ) 
* Filtrer l'extraction pou n'avoir que celle qui contienne un pattern définir ( --imgsPattern votre pattern ) 
* Définir si on veut avoir le nom du service ET l'image ou uniquement l'image ( 'getImg', 'getImgOnly' )

Voici un exemple d'utilisation du script :

```bash
$ ./extractImgDockerCmp.py -f docker-compose.yml  getImgOnly --imgsPattern "harbor.x3rus.com"
harbor.x3rus.com/xerus/x3-webdav

$ ./extractImgDockerCmp.py -f docker-compose.yml  getImg --imgsPattern "harbor.x3rus.com"                                           
{'x3-webdav': 'harbor.x3rus.com/xerus/x3-webdav'}
```

Si nous avions plusieurs conteneur nous aurions plusieurs ligne bien entendu. J'ai donc mis à jour le script Makefile afin de prendre en considération celle nouvelle méthode que ce soit pour la compilation des images ou du processus d'envois vers le docker registry.

```bash
PATTERN-IMG = harbor.x3rus.com
SCRIPT-EXTRACT-IMGNAME-DCK = "../scripts/dockers/extractImgDockerCmp.py"
DCK-CMP-FILENAME = docker-compose.yml
GIT-COMMIT-HASH := $(shell git rev-parse --short HEAD)

CMD-extract-img-name =${SCRIPT-EXTRACT-IMGNAME-DCK} -f ${DCK-CMP-FILENAME}  getImgOnly --imgsPattern "${PATTERN-IMG}"

[ ... OUTPUT COUPÉ ... ]

build-latest:
	# Build images 
	docker-compose build 

	# Read docker-compose search image for the private docker registry and set the tag with the commit hash
	$(foreach img, $(shell ${CMD-extract-img-name} ) \
		, docker tag $(img):latest ${img}:${GIT-COMMIT-HASH} ; )

push-to-registry:
	# Push images to the registry
	$(foreach img, $(shell ${CMD-extract-img-name} ) \
		, docker push $(img):latest && docker push ${img}:${GIT-COMMIT-HASH} ; )

```

Donc comme vous pouvez le lire , j'ai mis en place des variables au début contenant l'ensemble de la commande qui elle même est composé de variable. 

Par la suite j'ai fait une boucle for , il serait faux de dire que j'ai pas galérai , je n'avais fait de boucle for dans un Makefile :P.

Donc j'appelle mon script qui fait l'extraction , chaque ligne est stocké dans la variable img définie dans l'instruction __foreach__ par la suite je fait le docker push de l'image avec le tag latest ainsi que le docker push avec le git commit hash.

En écrivant ses ligne je me dit que je devrais extraire le tag depuis le docker-compose.yml et définir latest uniquement s'il y a rien ... Ha well , ça sera pour la prochaine fois que je travaille sur ce script :D. Faut bien se garder un peu de plaisir :P.

J'ai donc atteint mon but , avoir le support multi-images , dynamiquement , selon un critère pour MON docker registry depuis une source unique standardisé , on mettra sous silence le tag latest :P.

### (4) Validation si le conteneur est déjà présent dans le docker registry

Petit rappel du processus mise en place en quelques ligne , car nous discutons , on prend du temps sur des problèmes on analyse, mais parfois on oublie le principe ou l'essence du traitement donc j'aimerai simplement redéfinir avec vous le processus en place .

1. Nous avons des développeurs ou un administrateur système qui joue avec ces conteneurs qui sont TOUS contenu dans UN dépôt git , séparer à l'aide de répertoire dédié pour chacun.
2. Nous désirons mettre en place une tâches Jenkins , qui va nous permettre de compiler , éventuellement valider le fonctionnement / test fonctionnel (si l'instruction dans le Makefile est présent) . La liste des conteneurs / répertoire à traiter sont passés en paramètre 1 ou plusieurs , le déclencheur peut être humain ou planifier (commit hook). 
3. Le système va faire une validation , si le conteneur doit être compiler selon des critères, en prenant la liste des répertoires à valider :
    * Numéro du commit , permet de faire une validation uniquement depuis un commit id définie .
    * Quel est l'utilisateur qui a commité dans le dépôt.
    * Le message contenu dans le commit est-ce qu'elle contient un pattern indiquant de ne pas le prendre en considération
4. Suite à l'étape 3 la liste des répertoires à traiter sera possiblement identique ou réduite selon les critères et le résultat de la validation . Avec cette nouvelle liste nous validons si le docker registry  contient déjà l'image du conteneur que nous désirons compiler avec le commit id comme tag. Une nouvelle liste de répertoire est retourné avec la liste des conteneur à compiler.

Nous avons déjà poussé les conteneurs et dans la section [Validation de la présence du conteneur avec le numéro de tag](#Validation-de-la-présence-du-conteneur-avec-le-numéro-de-tag) nous avons fait un script pour extraire la liste des conteneurs dans le docker registry. 
En d'autre mot il ne reste plus qu'à sortir la colle , les clous , le marteau et le scotch ( ici je parle de papier collant , mais bon libre à vous pour l'interprétation :P ) . 

Voici l'extraction du contenu du stage **BuildDockers** : 

```
         stage('BuildDockers') {
            when {                    
                expression {           
                    dir('dockers') {   

                        // Version avec le code de retour                      
                        LST_DCKs = sh( returnStdout: true,                     
                                        script: 'python3 ../scripts/jenkins/gitBuildValidation.py --jenkins --include-dir $DOCKER_NAME --exclude-user BobLeRobot'                                    
                                       )                                       

                        // ATTENTION : dans le retour la variable contient un espace a la fin ...
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
```

Toujours dans la section **When**, je combine les critères de validation (__gitBuildValidation.py__ et __dockerAlreadyInRegistry.py__ ) , je démarre avec la variable **\$DOCKER\_NAME** contenant la liste des répertoires à traiter par la suite j'utilise **LST\_DCKs** contenant la liste post-validation.

Le script dockerAlreadyInRegistry.py est disponible sur github bien entend : [dockerAlreadyInRegistry.py](https://raw.githubusercontent.com/x3rus/training/master/jenkins-pipeline-et-dockers/depot-dockers-pour-gitlab/scripts-projects/jenkins/dockerAlreadyInRegistry.py) .

Je vois ce script comme un wrapper des 2 autres réalisé précédemment  :

* [extractImgDockerCmp.py](https://raw.githubusercontent.com/x3rus/training/master/jenkins-pipeline-et-dockers/depot-dockers-pour-gitlab/scripts-projects/dockers/extractImgDockerCmp.py) : Pour rappel permet d'extraire les images contenue dans un docker-compose.yml
* [dockerRegistryValidation.py](https://raw.githubusercontent.com/x3rus/training/master/jenkins-pipeline-et-dockers/depot-dockers-pour-gitlab/scripts-projects/dockers/dockerRegistryValidation.py) : Communique avec le docker registry , via l'API de harbor pour extraire savoir si une image de conteneur est présent.

Rapidement le scripts  :

* Prend en paramètre les répertoires à valider.
* Extrait depuis le fichier docker-compose.yml la liste des images qui doivent être compilé.
* Communique avec le docker registry pour chaque image afin de savoir si l'image est déjà présent avec le tag du commit id en cours.
* Retour la liste des répertoires qui doivent être compilé , en d'autre mot dont les images ne sont pas déjà présent dans le docker registry.

Si aucun conteneur ne doit être valider le script retourne __No\_Docker\_img\_to\_build__.

Pas plus compliquer que ça ... bon honnêtement ça m'a pris pas mal de temps réaliser ce petit projet à temps perdu , mais très intéressant.

### Pipeline Final

Voici donc le résultat de la configuration du Pipeline final : 

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

## Prochaine étapes ou piste d'amélioration

Voici des points d'améliorations pour la suite, aucune garantie que je vais le faire mais au moins j'aurais une trace si l'envie m'en prend :P.

1. Corriger le problème dans le Makefile qui pousse vers le registry par défaut avec latest , l'extraction depuis le docker-compose.yml devrait être modifier pour que s'il y a un tag le pousser avec ce dernier , sinon pousser avec latest . Temps requis du changement je pense qu'en 2 ou 3 heures avec période de testes et validation ça serait fait.
2. Définir la description du Pipeline dans le dépôt du projet, afin de conserver l'ensemble des informations dans le dépôt .
3. J'ai beaucoup de variable et d'argument un fichier de configuration pourrait être intéressant pour simplifier l'écriture et surtout le déplacement de la solution dans un autre environnement.
4. En corrélation avec le point ci-dessus voir pour faire un package pip , ceci permettrai d'avoir les binaires dans des paths convenable. 
5. Convertir les Makefile en format maven , bon ça c'est vraiment pas requis mis j'aimerai monté en compétence avec Maven :P .

En d'autre mot la solution est loin d'être parfaite, mais comme toujours c'est un échange d'un cheminement que j'ai parcouru qui vous permettra peut-être de réaliser autre chose de très intéressent .


