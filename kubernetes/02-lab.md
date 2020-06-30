# Description

Pour être en mesure d'explorer et de s'amuser avec Kubernetes nous allons mettre en place un laboratoire :), nous ne pouvons pas utiliser docker pour démarrer des instances kubernetes malheureusement. En réalité je pense qu'il existe un projet pour cela malheureusement, je trouve la solution pas idéal, alors nous allson mettre en place des machines virtuel avec virtualBox et vagrant .

Vagrant URL : https://www.vagrantup.com/

# Creation environnement Lab

Fichier Vagrant de référence : https://github.com/ecomm-integration-ballerina/kubernetes-cluster/blob/master/Vagrantfile dispo : [./data/Vagrantfile-original](./data/Vagrantfile-original)

Plus nice aussi : https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/

Mon fichier : [./data/Vagrantfile](./data/Vagrantfile)

```

$ vagrant up

$ vagrant status
Current machine states:

k8s-head                  running (virtualbox)
k8s-node-1                running (virtualbox)
k8s-node-2                running (virtualbox)

$ vagrant ssh k8s-head
Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.4.0-170-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage


4 packages can be updated.
0 updates are security updates.

New release '18.04.3 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


vagrant@k8s-head:~$
```

Sur la machine :

```
vagrant@k8s-head:~$ docker ps
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS               NAMES
f561f1d85675        7d54289267dc           "/usr/local/bin/ku..."   16 minutes ago      Up 16 minutes                           k8s_kube-proxy_kube-proxy-xbcgf_kube-system_6a9cc761-bcb5-44bf-a4d8-a54a26bb3386_0
ab88f945de20        k8s.gcr.io/pause:3.1   "/pause"                 16 minutes ago      Up 16 minutes                           k8s_POD_kube-proxy-xbcgf_kube-system_6a9cc761-bcb5-44bf-a4d8-a54a26bb3386_0
36633ff9af28        5eb3b7486872           "kube-controller-m..."   16 minutes ago      Up 16 minutes                           k8s_kube-controller-manager_kube-controller-manager-k8s-head_kube-system_b64ffdf4ab40fdde937d37d313e87df9_0
152b2a6de2b9        303ce5db0e90           "etcd --advertise-..."   16 minutes ago      Up 16 minutes                           k8s_etcd_etcd-k8s-head_kube-system_df543c6f7c7ec16eb8a0ef7249329342_0
a4fd3049c70f        0cae8d5cc64c           "kube-apiserver --..."   16 minutes ago      Up 16 minutes                           k8s_kube-apiserver_kube-apiserver-k8s-head_kube-system_180cab5a788a443c48bc06b2edaa1dff_0
d639c9a4a246        78c190f736b1           "kube-scheduler --..."   16 minutes ago      Up 16 minutes                           k8s_kube-scheduler_kube-scheduler-k8s-head_kube-system_ff67867321338ffd885039e188f6b424_0
bf0b515bb2bd        k8s.gcr.io/pause:3.1   "/pause"                 16 minutes ago      Up 16 minutes                           k8s_POD_kube-controller-manager-k8s-head_kube-system_b64ffdf4ab40fdde937d37d313e87df9_0
1c01c147caee        k8s.gcr.io/pause:3.1   "/pause"                 16 minutes ago      Up 16 minutes                           k8s_POD_kube-scheduler-k8s-head_kube-system_ff67867321338ffd885039e188f6b424_0
8e5cd277e564        k8s.gcr.io/pause:3.1   "/pause"                 16 minutes ago      Up 16 minutes                           k8s_POD_kube-apiserver-k8s-head_kube-system_180cab5a788a443c48bc06b2edaa1dff_0
cfe4e4a5845a        k8s.gcr.io/pause:3.1   "/pause"                 16 minutes ago      Up 16 minutes                           k8s_POD_etcd-k8s-head_kube-system_df543c6f7c7ec16eb8a0ef7249329342_0


vagrant@k8s-head:~$ kubectl  get nodes
NAME         STATUS     ROLES    AGE   VERSION
k8s-head     NotReady   master   18m   v1.17.0
k8s-node-1   NotReady   <none>   16m   v1.17.0
k8s-node-2   NotReady   <none>   14m   v1.17.0

vagrant@k8s-head:~$ kubectl  get namespaces
NAME              STATUS   AGE
default           Active   19m
kube-node-lease   Active   19m
kube-public       Active   19m
kube-system       Active   19m


vagrant@k8s-head:~$ kubectl  -n default  get pods
No resources found in default namespace.
vagrant@k8s-head:~$ kubectl  -n kube-system  get pods
NAME                               READY   STATUS    RESTARTS   AGE
coredns-6955765f44-hwbpx           0/1     Pending   0          19m
coredns-6955765f44-kzt62           0/1     Pending   0          19m
etcd-k8s-head                      1/1     Running   0          19m
kube-apiserver-k8s-head            1/1     Running   0          19m
kube-controller-manager-k8s-head   1/1     Running   0          19m
kube-proxy-kb8xb                   1/1     Running   0          15m
kube-proxy-nm5pj                   1/1     Running   0          17m
kube-proxy-xbcgf                   1/1     Running   0          19m
kube-scheduler-k8s-head            1/1     Running   0          19m

$ vagrant halt
==> k8s-node-2: Attempting graceful shutdown of VM...
==> k8s-node-1: Attempting graceful shutdown of VM...
==> k8s-head: Attempting graceful shutdown of VM...
20:05 xerus@goishi [~/git/formations/kubernetes/vagrant/data] $ 
  [ kubernetes ✭ | ● 1 ✚ 1 …49 ] ✔  $ vagrant status
Current machine states:

k8s-head                  poweroff (virtualbox)
k8s-node-1                poweroff (virtualbox)
k8s-node-2                poweroff (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.

```
