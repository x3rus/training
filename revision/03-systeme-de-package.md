# Présentation du système packages

## Concept de l'installation de logiciel sous GNU/Linux

Voici comment le concept d'installation de logiciel sous GNU/Linux fonctionne : premièrement, un grand nombre de logiciels sont fournis / disponibles par la distribution GNU/Linux que vous avez choisie. La majorité des distributions offrent une gamme de logiciels pour votre usage et, 95% du temps, vous trouverez le logiciel dans la liste disponible avec le gestionnaire de packages.

Si vous ne trouvez pas le logiciel ou que la version disponible n'est pas celle désirée, il existe des repository qui vous permettent d'étendre le choix de logiciels disponibles. Pour se faire, vous configurerez votre gestionnaire de package afin qu'il cherche les packages à ce nouvel endroit, en plus de la distribution. Encore une fois, vous avez avantage à avoir vos logiciels gérés par un gestionnaire de packages, vous assurant que les dépendances sont bien respectés et, a priori, les packages fonctionneront pour votre version de GNU/Linux. Bien entendu, il est important de faire attention aux repository ajoutés ; il faut s'assurer qu'ils ont une bonne réputation afin de ne pas installer des logiciels malveillants sur son Linux .

Dans la situation où personne ne fournit le logiciel, mais que ce dernier est libre, vous pouvez télécharger le logiciel et en faire l'installation manuellement en compilant le programme depuis les sources. Dans ce cas, il n'y a aucune gestion des dépendances ; il peut être ardue de faire l'installation de cette manière, surtout quand on débute...

Dans le cas où le logiciel est privatif, il faut utiliser l'installeur fourni par le programme et, bien entendu, télécharger le logiciel depuis le site officiel du produit.

J'aimerai refaire mention que 95% des logiciels sont installables avec les packages fournis par la distribution. Alors, avant de vous casser la tête, regardez s'il est disponible!

### Définition d'un package

Un package est une archive contenant des données et/ou des programmes ainsi que les informations nécessaires à une installation correcte de ceux-ci sur le système. Un package est constitué d'un seul fichier, qui n'est pas un exécutable. Il est pris en charge par un programme dédié : le gestionnaire de package.

Il existe plusieurs types différents de package :

* **[RPM]** : pour Redhat Package Manager. C'est le type de package le plus utilisé sous Linux. Ces packages gèrent les dépendances et les scripts d'installation/désinstallation.
* **[DEB]** : le type de package utilisé par la distribution Debian et ses dérivés. Il gère les scripts et les dépendances de façon plus fine que RPM.
* **[tar.gz]** : utilisé par les distributions du type slackware. Il s'agit d'une simple archive contenant également les scripts d'installation.
* **[pkg]** : cette extension peut désigner plusieurs types de package différents utilisés par des Unix propriétaires, comme solaris ou QNX.

Il faut noter que les différentes saveurs libres de BSD utilisent un système différent, appelé ports, où les programmes sont systématiquement recompilés.

#### Gestion des dépendances

La gestion des dépendances est un des gros avantage des systèmes de packages.

Chaque package contient une liste des fonctionnalités qu'il fournit. Cela commence par le nom du package lui-même, cela peut également être un programme particulier, une bibliothèque générique ou dans une version plus particulière ou encore une fonctionnalité plus "diffuse'',  telle que "serveur ftp'' pour apache, ou "gestionnaire de téléchargement'' pour wget.

Ensuite, les packages vont contenir une liste des fonctionnalités qui leurs sont nécessaires pour être fonctionnels2.

Lors de l'installation, le gestionnaire de package va vérifier que toutes les dépendances sont vérifiées et que l'installation du nouveau package ne va pas écraser des fichiers d'autres packages. Sinon, il refusera d'installer. Il reste possible de forcer l'installation à ses risques et périls.

De même, à la désinstallation d'un package, le gestionnaire de package vérifie que la suppression de ce(s) package(s) ne gène pas le fonctionnement d'autres packages. Une fois encore, on peut ne pas tenir compte des dépendances, mais cela peut s'avérer assez grave (forcer la désinstallation de la glibc est le parfait exemple de ce qu'il faut faire si on veut foutre en l'air son système).

#### Script d'installation et de dé-installation

Si, pour installer une documentation, il est suffisant d'en décompresser les fichiers, il n'en va pas forcément de même pour des programmes, et encore moins pour des bibliothèques, dont l'installation nécessitera d'effectuer des opérations sur le systèmes pour que le contenu du package soit pleinement fonctionnel.

C'est à cela que servent les scripts d'installation/désinstallation, qui se présentent sous la forme de simples scripts shell (au standard sh). Ils sont au nombre de quatre :

* **[le script de pré-installation]** : il effectue toutes les opérations préparatoires à l'installation.
* **[le script de post-installation]** : s'occupe de toute la configuration post-installation, par exemple enregistrer de nouvelles bibliothèques, ou générer une configuration en accord avec la machine sur laquelle il est installé.
* **[le script de pré-désinstallation]** : s'occupe des opérations à effectuer avant de désinstaller le package. Par exemple, s'il s'agit d'un serveur quelconque, il faut arrêter celui-ci avant de le désinstaller.
* **[le script de post-désinstallation]** : est chargé des opérations à effectuer après désinstallation.

#### Les packages et Internet

Le système de package est indépendant d'Internet, comme chaque package contient la liste des dépendances dont il a besoin pour fonctionner, il n'a pas besoin d'une source externe. Chaque système de package conserve localement une Base de données, avec l'information des packages installés sur le système. Cette dernière est interrogée s'il y a besoin de valider des dépendances lors de l'installation. 

* **deb** : /var/lib/dpkg : contient l'ensemble de l'information sur les packages présents sur le système et le logiciel, et gère des packages sous debian. Porte le nom de DPKG
* **rpm** : /var/lib/rpm ,   contient l'ensemble de l'information sur les packages présent sur le système et le logiciel, et gère des packages sous RedHat. Porte le nom de RPM

Le système de package indique la liste des dépendances à résoudre pour pouvoir installer le package. De nos jours, des outils sont nées qui permettent de rechercher directement sur Internet ces packages, de les télécharger et de fournir le fichier au gestionnaire de package.

![](./imgs/dpkg-apt-rpm-yum.png)

Dans le prochain chapitre, nous allons voir l'utilisation de ses 2 gestionnaires de package.

## Système de package Debian/Ubuntu


Les paquets contiennent généralement tous les fichiers nécessaires pour implémenter un ensemble de commandes ou de fonctionnalités. Il y a deux sortes de paquets Debian :

* Les paquets binaires contenant les exécutables, les fichiers de configuration, les pages de manuel ou d'info, les informations de copyright et d'autres documentations. Ces paquets sont distribués sous un format d'archive spécifique à Debian (voir Quel est le format d'un paquet binaire Debian ?, Section 7.2). Ils sont habituellement reconnaissables par l'extension « **.deb** ». Ils peuvent être installés en utilisant l'utilitaire dpkg (éventuellement avec une interface comme aptitude) ; vous trouverez plus de détails dans les pages de manuel.
* Les paquets sources sont constitués d'un fichier.dsc décrivant le paquet source (incluant le nom des fichiers suivants), un fichier.orig.tar.gz contenant les sources originales non modifiées, au format tar compressé, et, habituellement, un fichier.diff.gz contenant les modifications spécifiques à Debian par rapport la source originale. L'utilitaire dpkg-source permet l'archivage et le désarchivage des sources Debian ; vous trouverez plus de détails dans les pages de manuel. (Le programme apt-get peut être utilisé comme une interface pour dpkg-source.)

Les outils de gestion de paquets Debian peuvent être utilisés pour :

* manipuler ou administrer les paquets ou une partie des paquets,
* administrer les modifications locales (« overrides ») des fichiers d'un paquets,
* aider les développeurs dans la construction de paquets et
* aider les utilisateurs dans l'installation de paquets résidant sur un serveur FTP distant.

Le nom des paquets binaires Debian se conforme à la convention suivante : <foo>\_<NuméroVersion>-<NuméroRévisionDebian>\_<DebianArchitecture>.deb

### Outils de gestion des packages

```
	 dpkg      – installation de paquets Debian
     apt-get   – frontal pour APT en ligne de commande
     aptitude  – frontal avancé pour APT en mode texte et ligne de commande
     synaptic  – frontal pour APT en mode graphique GTK
     dselect   – gestion des paquets à l'aide de menus
     tasksel   – installation de tâches
```

Ces outils ne sont pas tous des alternatives. Par exemple dselect utilise à la fois APT et dpkg.

APT utilise /var/lib/apt/lists/* pour suivre les paquets disponibles tandis que dpkg utilise /var/lib/dpkg/available. Si vous avez installé des paquets directement en utilisant aptitude ou un autre frontal pour APT et que vous voulez utiliser dselect pour installer des paquets, assurez-vous de mettre à jour le fichier /var/lib/dpkg/available en sélectionnant **[M]**ise à jour dans le menu de dselect (ou en exécutant dselect update).

* **apt-get** récupère automatiquement les paquets dont un paquet demandé dépend. Il n'installe pas les paquets recommandés ou suggérés par le paquet demandé.
* **aptitude** au contraire peut être configuré pour installé les paquets recommandés ou suggérés.
* **dselect** présente à l'utilisateur une liste de paquets qu'un paquet sélectionné recommande ou suggère et permet de les sélectionner ou pas.

#### Présentation de dpkg

**dpkg** (pour debian package) est un outil logiciel en ligne de commande chargé de l'installation, la création, la suppression et la gestion des paquets Debian (.deb), le type de paquets traités par Ubuntu et Debian. Pour l'installation de paquets, dpkg dispose d'une interface graphique, GDebi, que vous pouvez utiliser si vous préférez éviter la ligne de commande.

À la différence de la commande apt-get, de la Logithèque, ou de l'interface graphique GDebi, dpkg est un outil qui ne gère pas les dépendances. Ainsi en cas de conflit ou bien lorsque seuls certains paquets impliquant trop de dépendances font défaut, l'utilisation de cet outil devient presque indispensable. Synaptic et d'autres gestionnaires de paquets utilisent justement cet outil pour résoudre certains problèmes caractéristiques. Il permet donc de 'jouer' sur un seul paquet (installation, suppression, reconfiguration ) sans bouleverser les dépendances. Parmi ses autres fonctions dpkg permet aussi d'avoir des informations précises telles que l'état ou la description détaillée, des paquets disponibles.

* **Commande disponible**
	* Installation de package , préalablement téléchargé

	```bash
	utilisateur@hostname:~$ sudo dpkg -i le_package.deb
	```

	* Suppression de package, suppression simple de binaire et suppression avec purge des fichiers de configuration ou autre fichiers déployer par l'application.

	```bash
		# Suppression du package , binaire
	utilisateur@hotname:~$ sudo dpkg -r  le_package
 
		# Suppression complète , binaire + fichier de configuration
	utilisateur@hotname:~$ sudo dpkg -P  le_package
	```

	* Lister les packages installer 

	```bash
		# Liste l'ensemble des packages
	utilisateur@hostname:~$ dpkg -l
 
		# recherche un package préalablement installé
	utilisateur@hostname:~$ dpkg -l rsync
 
		# Liste le contenu d'un package
	utilisateur@hostname:~$ dpkg -L rsync
	```

	* Recherche de fichier dans le système de packages.

	```bash
		# recherche dans les packages quelle package possède ce fichier
	utilisateur@hostname:~$ dpkg -S /etc/passwd
	```

#### Présentation des outils apt

Les dépôts **APT** sont des "sources de logiciels", concrètement des serveurs qui contiennent un ensemble de paquets. À l'aide d'un outil appelé gestionnaire de paquets, vous pouvez accéder à ces dépôts et, en quelques clics de souris, vous trouvez, téléchargez et installez les logiciels de votre choix.

Ubuntu intègre aussi de base un outil nommé Gestionnaire de mises à jour, qui vérifie périodiquement dans les dépôts auxquels vous avez accès que vous disposez des dernières versions de vos logiciels et bibliothèques ; dans le cas contraire, il vous permet de les mettre à jour automatiquement.

Les dépôts auxquels Ubuntu accède par défaut, afin de vérifier les mises à jour logicielles et rechercher les logiciels à installer, sont les dépôts maintenus par la Fondation Ubuntu (le groupe s'occupant du développement d'Ubuntu) et votre CD d'installation. Vous pouvez étendre (ou réduire) la liste des dépôts accessibles par votre système en ajoutant ou retirant des dépôts d'autres distributeurs. (voir : modifier les dépôts)

Sous Ubuntu, la grande majorité des applications sont disponibles dans les dépôts officiels et sont directement installables à l'aide d'outils graphiques comme [La Logithèque Ubuntu](http://doc.ubuntu-fr.org/software-center).

Rien ne vous empêche d'installer des logiciels en provenance d'autres dépôts ou d'autres sites Web, mais soyez vigilants, car ces programmes ne sont pas testés par l'équipe de développement d'Ubuntu et peuvent donc être dangereux pour votre système, ou simplement mal s'intégrer à votre environnement, comporter des bogues…

Dépôt officiel

L'accès aux dépôts officiels est configuré automatiquement. Ils regroupent des dépôts de base, des dépôts de mises à jour et de sécurité. Toutes les branches des dépôts principaux sont divisées en quatre sections :

* Sections Main et Restricted, maintenues par les développeurs d'Ubuntu
	Les sections main (paquets tout à fait libres) et restricted (paquets non-libres) contiennent des paquets maintenus par les développeurs d'Ubuntu pour toute la durée de vie de la version d'Ubuntu que vous utilisez.

* Sections Universe et Multiverse, maintenues par la communauté
    Les sections universe et multiverse des dépôts officiels contiennent des paquets maintenus par la communauté. La Fondation Ubuntu ne contrôle pas ces paquets ; ils sont analysés par un comité d'utilisateurs. La section universe contient uniquement des paquets libres et la section multiverse, des paquets non-libres. L'accès à ces deux sections est paramétré par défaut.

##### Outil apt-cache

apt-cache est une interface permettant d'effectuer quelques manipulations basiques sur les paquets, installés ou non, disponibles dans la liste mise en cache des paquets des dépôts APT configurés. Il ne nécessite pas les droits d'administration.

* Recherche de package

```bash
utilisateur@hostname:~$ apt-cache search le_logiciel
```

* Affiche l'information détaillé du package

```bash
utilisateur@hostname:~$ apt-cache showpkg le_package
```

* Affiche les dépendances du package 

```bash
utilisateur@hostname:~$ apt-cache depends le_package
```

##### Outil apt-get

**A**dvanced **P**ackaging **T**ool est un système complet et avancé de gestion de paquets, permettant une recherche facile et efficace, une installation simple et une désinstallation propre de logiciels et utilitaires. Il permet aussi de facilement tenir à jour votre distribution Ubuntu avec les paquets en versions les plus récentes et de passer à une nouvelle version de Ubuntu, lorsque celle-ci est disponible.

* **Commande**
	* Mise à jour du cache local contenant la liste des packages
	  Le système apt-get ne communique pas continuellement sur Internet , le système réalise un cache local de la liste des packages disponibles. Ceci a l'avantage de ne pas perdre du temps à chaque installation , le mauvais coté est qu'il faut mettre à jour cette liste manuellement, sinon lorsque vous essayerez d'installer un package le apt-get vous donnera l'erreur : "404 not found" du package désirer. Pour mettre à jour la liste tape la commande suivante :

	```bash
		utilisateur@hostname:~$ sudo apt-get update
		Ign http://us.archive.ubuntu.com precise InRelease
		Ign http://us.archive.ubuntu.com precise-updates InRelease
		Ign http://us.archive.ubuntu.com precise-backports InRelease
		Ign http://security.ubuntu.com precise-security InRelease
		Hit http://us.archive.ubuntu.com precise Release.gpg
		Hit http://security.ubuntu.com precise-security Release.gpg
		Hit http://us.archive.ubuntu.com precise-updates Release.gpg
		Hit http://security.ubuntu.com precise-security Release
		Hit http://us.archive.ubuntu.com precise-backports Release.gpg
		Hit http://us.archive.ubuntu.com precise Release
		[ .... OUTPUT COUPÉ ...]
	```
