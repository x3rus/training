
[[_TOC_]]

# Introduction

Telle que présenté lors de l'introduction DevOps , un des principes fondamental et d'être en mesure de déployer les applications rapidement , nous l'avons vu dans le processus de l'intégration continue. En d'autre mot lors d'un changement de code ou sur une base régulière, chaque jour par exemple, nous devons être en mesure de déployer une nouvelle version de l'application. Cette opération doit être réalisé de manière identique, à chaque déploiement, il serait complètement incohérent d'avoir un mécanisme différent à chaque fois. Le requis d'un déploiement rapide n'est pas réellement présent, cependant si vous devez passer 6 heures pour réalisé chaque déploiement manuellement, vous passerez l'ensemble de votre temps à réalisé cette opération. Par le fait même après 2 semaines à réalisé ces opérations répétitive, votre niveau de motivation sera très bas !!

Il existe plusieurs solution de déploiement , **puppet** , **ansible**, **salt** , **cfengin** , ... Je ne vais pas vous dire que **Ansible** est le meilleur , cependant c'est celui qui est très populaire et avec le support de RedHat assure une garantie de stabilité et d'évolution. Par la suite chacun on leur avantage et inconvénient , l'important est d'en maitriser UN par la suite l'apprentissage des autres est plus simple.

Information sur [ansible depuis wikipedia](https://fr.wikipedia.org/wiki/Ansible_\(logiciel\))

> Ansible est une plate-forme logicielle libre pour la configuration et la gestion des ordinateurs. Elle combine le déploiement de logiciels multi-nœuds, l'exécution des tâches ad-hoc, et la gestion de configuration. Elle gère les différents nœuds par-dessus SSH et ne nécessite l'installation d'aucun logiciel supplémentaire à distance sur eux. Les modules fonctionnent grâce à JSON et à la sortie standard et peuvent être écrits dans n'importe quel langage de programmation. Le système utilise YAML pour exprimer des descriptions réutilisables de systèmes.
> 
> La plate-forme a été créée par Michael DeHaan, l'auteur de l'application serveur de provisioning Cobbler et coauteur du cadre de développement Func pour l'administration à distance. Les utilisateurs de Ansible comprennent le Fedora Project, Hewlett-Packard Allemagne, Basho Technologies, ALE International et l'Université Aristote de Thessalonique, ainsi qu'Airbus, La Poste et la Société générale. Il est inclus dans le cadre de la distribution Linux Fedora, propriété de Red Hat inc., et est également disponible pour Red Hat Enterprise Linux, CentOS et Scientific Linux via les paquets supplémentaires "Extra Packages for Enterprise Linux" (EPEL)5.
> 
> Ansible Inc. était la société derrière le développement commercial de l'application Ansible. Red Hat rachète Ansible Inc. en octobre 2015.
> 
> Le nom Ansible a été choisi en référence au terme Ansible choisi par Ursula Le Guin dans ses romans de science-fiction pour désigner un moyen de communication plus rapide que la lumière.

TODO: Ajout de plus d'introduction avec le pull / push des agents 

## Référence :

* [Wikipedia ansible](https://fr.wikipedia.org/wiki/Ansible_(logiciel))

TODO : plus de référence SVP

# Mise en place d'un environnement

Afin d'être en mesure de réaliser les testes démontré dans cette documentation nous allons mettre en place un conteneur qui nous permettra de refaire l'ensemble du matériel ci-dessous. 
J'ai choisie de la mettre dans un conteneur, mais libre à vous de choisir le mode de déploiement désiré. La recette est dans le [Dockerfile](./dockers/ansible )


TODO : mettre en forme :

```bash
$ docker-compose  run --rm ansible 
ansible-playbook 2.5.2
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 2.7.12 (default, Dec  4 2017, 14:50:18) [GCC 5.4.0 20160609]

$ docker-compose  run --rm --entrypoint=/bin/bash ansible
root@1f26260af83d:/# 
root@1f26260af83d:/# 

```
