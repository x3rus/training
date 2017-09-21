## Mise en place de la base [Pratique] 

Nous allons voir un peu la base de la configuration du serveur et de la communication avec 2 agents, bien entendu pour faciliter ma présentation de je vais utiliser des conteneurs docker. Ici je vais utiliser des conteneurs docker pour simuler des machines virtuel ou physique , l'utilisation de puppet dans un conteneur n'est pas claire pour moi. En fait je ne crois pas que puppet soit approprié , car nous avons l'ensemble de la définition du conteneur dans un fichier plan ( Dockerfile ) . 

Cependant il est toujours possible d'orchestrer vos conteneurs avec puppet , ce ne sera pas couvert dans la formations puppet , on fera peut-être une capsule sur le sujet ou PAS :P . Je vous donne donc des liens à consulter :

* https://docs.docker.com/engine/admin/puppet/#containers
* https://github.com/garethr/garethr-docker

Autre lien qui semble intéressant, mais je n'ai pas approfondie , prendre note de l'avertissement au début :P , https://github.com/vshn/puppet-in-docker

# NOTE :

* type langage https://docs.puppet.com/puppet/5.2/type.html

* __Puppet IDE__ : https://puppet.com/blog/geppetto-a-puppet-ide 


