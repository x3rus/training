
# Description

Comme toujours avant de voir le côté technique prenons le temps de combien où nous désirons aller. Depuis quelques temps nous avons vue l'utilisation de docker, que se soit des formations dockers pure où lors de la présentation de logiciel. Soyons honnête depuis que docker est disponible ceci à bien changé nos vie , d'administrateur , de développeur, d'utilisateur qui veut tester une application , ... 

Tranquillement nous avons mis en place des outils de autour pour s'amuser , heu non pas uniquement, mais pour mieux gérer nos conteneurs . Tranquillement nous arrivons au point d'avoir un lieu centraliser nous permettant de stocker nos images. 

Rapidement on va juste clarifier le vocabulaire, car bien souvent nous utilisons le terme docker comme un abus de langage . Il y a 2 type de conteneur :

* **Image** (docker image) : Ceci est le produit de la définition du fichier __Dockerfile__ qui permet d'indiquer comment construire l'image.
* **Conteneur** (docker conteneur): Ceci est le "docker" , bien souvent les personnes nomment le conteneur en exécution "docker", ceci est bien entendu un abus de langage, mais je suis le premier à le faire :P. Un conteneur est donc une image qui fut initialisé donc en exécution ou en arrêt. 

Si nous reprenons la représentation graphique des couches (__layers__) nous voyons clairement la distinction :

![](./imgs/docker-filesystems-multilayer-ORI.png)

Donc désolé pour cette clarification, mais vous savez comment ça se passe on veut parfois allé un peu vite et nous oublions de revenir à la base.

## Pourquoi un Docker Registry

Si vous êtes un développeur vous avez probablement un dépôt d'artefacts que vous utilisez déjà , que nous parlions de [Nexus de sonartype](https://www.sonatype.com/nexus-repository-sonatype) ou [Artefactory](https://www.artefactorylab.com/) , l'idée et l'objectif du docker registry est le même . 
Bon j'entends les administrateurs ou les nouveaux ce dire __Woww__ c'est quoi qui veut dire , clarifier c'est quoi un dépôt d'artefacts et par le fait même le docker registry.

### C'est quoi un Docker registry

Lors du développement logiciel, l'équipe va utiliser plusieurs modules ou librairie qui va composer l'application. L'objectif d'un dépôt d'artefacts est que si la librairie X version 1.2.1 fut déjà compilée, et qu'un développeur à besoin de compiler un bout de code qui à cette librairies comme dépendance au lieu de la recompiler il va la récupérer depuis le dépôt d'artefacts.
Bien entendu ceci s'applique pour l'ensemble des librairies nous pouvons donc passé le temps de compilation à quelques minutes au lieu de recompilé l'ensemble de l'application. 

Le dépôt d'artefact nous permettra aussi de conserver une historique des produits fini, tous comme le contrôleur de révision ( GIT, SVN, ...) nous permet de conserver l'historique des fichiers sources. 
Selon votre niveau de maturité, il y aura en plus des testes de validation ( Unit test, Moc , ... ) réalisé sur les librairies avant d'être transmise au dépôt d'artefacts augmentant le niveau de fiabilité du contenu. 

**Ok, Ok** ,  nous arrivons au docker registry , ça sera pas long :P. Je veux simplement vous démontrer qu'il n'y a rien de nouveau , le concept est déjà en place depuis bien longtemps. De plus nous voyons que le docker registry est dans un tout cohérent , dans la phase de développement. 

Le docker registry est comme une bibliothèque qui contient l'ensemble des **docker images** que vous avez déjà compilé et poussez vers le registry. Si vous désirez avoir un exemple de registry : [hub.docker.com](https://hub.docker.com/) , vous l'utilisez déjà en plus :D . Ce registry publique vous permet de faire des recherches, d'extraire une images pour une version spécifique (__tag__) , vous pouvez même pousser / stocker des images "gratuitement". 

### Pourquoi utiliser un docker registry 



####  UN Docker host

Si vous n'utilisez qu'une machine avec docker sur laquelle vous réalisez vos générations d'images et que l'exécution des conteneurs est réalisé sur la même machine , vous prenez pas la tête, vous n'en n'avez pas réellement besoin. En effet , vous avez un docker registry localement intégrer pour preuve que vous tapez la commande :

```bash
$ docker images 
```

Le système vous liste les images disponible localement , avec les tag , lors de la compilation d'un fichier Dockerfile l'image ce retrouve et vous avez aussi un copie des conteneurs que vous avez télécharger avec la commande : __docker pull__.


####  DEUX Docker host



### Pourquoi ne pas utiliser hub.docker.com

# Référence :

* Description :
    * https://blog.codeship.com/overview-of-docker-registries/

* Autre :
    * https://github.com/SUSE/Portus/tree/master/examples
    * http://port.us.org/docs/setups/2_containerized.html

