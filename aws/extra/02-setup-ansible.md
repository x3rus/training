
# Description 

Comme nous créons et détruisons des instances __AWS__ , il est très pénible de faire la configuration de **docker** et de l'utilisateur __ec2-user__ à chaque fois. Ceci est une perte de temps , et si on décide de conserver l'instance pour ne pas refaire la configuration c'est une perte d'argent.

Comme c'est toujours les même opérations, nous avons une belle opportunité d'automatiser le processus de configuration de la machine. J'ai choisi d'utiliser **ansible** , car je ne le connait pas :P , c'est donc une occasion de voir comment il fonctionne sur une petite configuration .

Voici les opérations réalisées manuellement lors de la création de l'instance :

```bash
[EC2-user@ip-172-31-60-4 ~]$ sudo yum install -y yum-utils && sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo  && sudo yum makecache fast && sudo yum install docker-ce

[ec2-user@ip-172-31-60-27 ~]$ curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
[ec2-user@ip-172-31-60-27 ~]$ sudo python get-pip.py
[ec2-user@ip-172-31-60-27 ~]$ sudo pip install docker-compose
[ec2-user@ip-172-31-60-27 ~]$ sudo systemctl start docker.service.
[ec2-user@ip-172-31-60-27 ~]$ sudo vim /etc/group # ajout de l'utilisateur ec2-user dans le group docker
```

## Point important 

* Connexion avec un utilisateur **non-root** 
* Réalisation des commandes avec **sudo**
* Clé ssh pré générer 


# Installation de Ansible sur un Ubuntu 16.04

```bash
sudo apt-get update 
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible
```

# Réalisation de la configuration 

* Réalisation du playbook pour ansible 

```yaml
- hosts:  AWS
  # Connexion as ec2-user et utilisation de sudo
  remote_user: ec2-user
  become: true  
  tasks:
  - name: setup yum utils package
    yum:
      name: yum-utils
      state: latest
  - name: add docker repository
    command: yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  - name: configue yum cache faster 
    command: yum makecache fast 
  - name: Install docker package
    yum:
      name: docker-ce
      state: latest
  - name: Get Pip installation package
    command: curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py"
  - name: Installation of pip
    command: python /tmp/get-pip.py
  - name: Installation of docker-compose
    command: pip install docker-compose
  - name: enable dockerd service
    systemd:
      name: docker.service
      state: started
      enabled: True
  - user:
      name: ec2-user
      groups: docker
      append: yes
```

* Configuration des variables d'environnement pour le hosts  __/etc/ansible/hosts__

```

[AWS]
52.15.42.42

[AWS:vars]
ansible_ssh_private_key_file=/etc/ansible/ssh_keys/aws_training

```

* Réalisation d'un test passant 

```bash
# ansible-playbook   playbooks/setup-dck.yml 

PLAY [AWS] ***************************************************************************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************************************************
The authenticity of host '52.15.42.42 (52.15.42.42)' can\'t be established.
ECDSA key fingerprint is SHA256:MfPZkTpESP9eN96mbK8mMY08NtDDWew94MrtOB1AT48.
Are you sure you want to continue connecting (yes/no)? yes
Enter passphrase for key '/etc/ansible/ssh_keys/aws_training': 
ok: [52.15.42.42]


``` 
